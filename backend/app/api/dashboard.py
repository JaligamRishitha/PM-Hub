from datetime import date, timedelta
from typing import List

from fastapi import APIRouter, Depends
from sqlalchemy import func as sqlfunc
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.cbs import CBS
from app.models.compensation_event import CompensationEvent
from app.models.milestone import Milestone
from app.models.milestone_payment import MilestonePayment
from app.models.project import Project
from app.models.safety_incident import SafetyIncident
from app.models.risk import Risk
from app.models.issue import Issue
from app.models.activity import ProjectActivity
from app.models.user import User
from app.schemas.dashboard import (
    BudgetVsActual,
    CashflowItem,
    DashboardSummary,
    DelayedMilestoneItem,
    OpenRiskItem,
    PlannedVsActualItem,
    UpcomingMilestone,
    PortfolioHealth,
    RiskHeatmapCell,
)

router = APIRouter(prefix="/api/dashboard", tags=["dashboard"])


def _compute_spi(activities):
    """Schedule Performance Index: earned schedule / planned schedule.

    Only considers activities that should have started by today
    (planned_start <= today) to avoid penalising future work.
    """
    if not activities:
        return 1.0
    today = date.today()
    total_planned = 0
    total_earned = 0
    for a in activities:
        # Only count activities whose planned start has passed
        if a.planned_start > today:
            continue
        duration = (a.planned_finish - a.planned_start).days or 1
        total_planned += duration
        completion = float(a.completion_pct or 0) / 100.0
        total_earned += duration * completion
    if total_planned == 0:
        return 1.0
    return round(total_earned / total_planned, 2)


def _compute_cpi(budget, actual, completion_pct=None):
    """Cost Performance Index: EV / AC.

    EV (Earned Value) = budget * completion%.
    AC (Actual Cost) = actual spend.
    If completion_pct is not provided, falls back to budget/actual.
    """
    if actual == 0:
        return 1.0
    if completion_pct is not None:
        ev = budget * (completion_pct / 100.0)
        return round(ev / actual, 2) if actual > 0 else 1.0
    return round(budget / actual, 2) if actual > 0 else 1.0


def _rag_status(value, green_threshold=0.95, amber_threshold=0.85):
    """Convert a ratio to RAG status."""
    if value >= green_threshold:
        return "Green"
    if value >= amber_threshold:
        return "Amber"
    return "Red"


@router.get("/summary", response_model=DashboardSummary)
def get_summary(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    projects = db.query(Project).all()
    total_projects = len(projects)
    active_projects = sum(1 for p in projects if p.status == "Active")
    delayed_projects = sum(1 for p in projects if p.status == "At Risk")

    all_milestones = db.query(Milestone).all()
    total_milestones = len(all_milestones)
    delayed_milestones = sum(1 for m in all_milestones if m.status == "Delayed")

    budget_row = db.query(
        sqlfunc.coalesce(sqlfunc.sum(CBS.budget_cost), 0),
        sqlfunc.coalesce(sqlfunc.sum(CBS.actual_cost), 0),
        sqlfunc.coalesce(sqlfunc.sum(CBS.forecast_cost), 0),
    ).first()
    total_budget = float(budget_row[0])
    total_actual_cost = float(budget_row[1])
    total_forecast = float(budget_row[2])

    total_contract = sum(float(p.contract_value or 0) for p in projects)
    total_project_budget = sum(float(p.total_budget or 0) for p in projects)

    active_ce = db.query(CompensationEvent).filter(CompensationEvent.status == "Pending").count()
    open_incidents = db.query(SafetyIncident).filter(SafetyIncident.status == "Open").count()
    open_risks = db.query(Risk).filter(Risk.status == "Open").count()

    overdue_issues = db.query(Issue).filter(
        Issue.status.in_(["Open", "In Progress"]),
        Issue.due_date < date.today(),
    ).count()

    # Portfolio-level SPI
    all_activities = db.query(ProjectActivity).all()
    schedule_health = min(_compute_spi(all_activities) * 100, 100)

    # Portfolio-level CPI: weighted average of per-project CPIs (weighted by actual cost)
    # Weight by actual spend so projects with real cost data contribute more
    project_cpis = []
    for p in projects:
        p_cbs = db.query(
            sqlfunc.coalesce(sqlfunc.sum(CBS.budget_cost), 0),
            sqlfunc.coalesce(sqlfunc.sum(CBS.actual_cost), 0),
        ).filter(CBS.project_id == p.id).first()
        p_budget = float(p_cbs[0])
        p_actual = float(p_cbs[1])
        if p_budget <= 0 or p_actual <= 0:
            continue
        p_avg = float(db.query(
            sqlfunc.coalesce(sqlfunc.avg(ProjectActivity.completion_pct), 0)
        ).filter(ProjectActivity.project_id == p.id).scalar())
        p_cpi = _compute_cpi(p_budget, p_actual, p_avg)
        # Cap individual project CPI at 2.0 before aggregation
        project_cpis.append((min(p_cpi, 2.0), p_actual))

    if project_cpis:
        total_weight = sum(w for _, w in project_cpis)
        cpi = sum(c * w for c, w in project_cpis) / total_weight if total_weight > 0 else 1.0
    else:
        cpi = 1.0
    cost_health = min(cpi * 100, 100)

    # Risk exposure score: sum of (probability × impact × cost_exposure) for open risks
    open_risk_list = db.query(Risk).filter(Risk.status == "Open").all()
    risk_exposure = sum(r.risk_score * float(r.cost_exposure or 0) for r in open_risk_list)

    # LD exposure across all projects
    ld_exposure = 0.0
    for p in projects:
        if p.contract_completion_date and not p.actual_completion_date:
            delay = (date.today() - p.contract_completion_date).days
            if delay > 0:
                ld = delay * float(p.daily_ld_rate or 0)
                cap = float(p.contract_value or 0) * float(p.ld_cap_pct or 10) / 100
                ld_exposure += min(ld, cap) if cap > 0 else ld

    # Margin
    margin_pct = 0.0
    if total_contract > 0:
        margin_pct = round((total_contract - total_actual_cost) / total_contract * 100, 1)

    # Safety score: percentage of resolved/closed incidents out of total
    total_incidents = db.query(SafetyIncident).count()
    resolved_incidents = db.query(SafetyIncident).filter(
        SafetyIncident.status.in_(["Resolved", "Closed"])
    ).count()
    safety_score = round((resolved_incidents / total_incidents) * 100, 1) if total_incidents > 0 else 100.0

    # Phase counts
    projects_gate_b = sum(1 for p in projects if (p.phase or "").lower() == "gate b")
    projects_gate_c = sum(1 for p in projects if (p.phase or "").lower() == "gate c")
    design_completion = sum(1 for p in projects if (p.phase or "").lower() == "design completion")
    construction = sum(1 for p in projects if (p.phase or "").lower() == "construction")
    commissioned = sum(1 for p in projects if (p.phase or "").lower() == "commissioned")

    return DashboardSummary(
        total_projects=total_projects,
        active_projects=active_projects,
        delayed_projects=delayed_projects,
        total_milestones=total_milestones,
        delayed_milestones=delayed_milestones,
        total_budget=total_project_budget,
        total_actual_cost=total_actual_cost,
        total_contract_value=total_contract,
        total_forecast_cost=total_forecast,
        active_compensation_events=active_ce,
        open_safety_incidents=open_incidents,
        open_risks=open_risks,
        overdue_issues=overdue_issues,
        schedule_health_pct=round(schedule_health, 1),
        cost_health_pct=round(cost_health, 1),
        ev_performance=round(min(cpi, 2.0), 2),
        risk_exposure_score=0,
        ld_exposure=round(ld_exposure, 2),
        margin_pct=margin_pct,
        safety_score=safety_score,
        projects_gate_b=projects_gate_b,
        projects_gate_c=projects_gate_c,
        design_completion=design_completion,
        construction=construction,
        commissioned=commissioned,
    )


@router.get("/upcoming-milestones", response_model=List[UpcomingMilestone])
def get_upcoming_milestones(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    today = date.today()
    future = today + timedelta(days=30)
    rows = (
        db.query(Milestone, Project.name)
        .join(Project, Milestone.project_id == Project.id)
        .filter(
            Milestone.planned_date >= today,
            Milestone.planned_date <= future,
            Milestone.actual_date.is_(None),
        )
        .order_by(Milestone.planned_date)
        .all()
    )
    return [
        UpcomingMilestone(
            id=m.id,
            project_name=pname,
            milestone_name=m.name,
            planned_date=m.planned_date.isoformat(),
            is_critical=m.is_critical,
        )
        for m, pname in rows
    ]


@router.get("/budget-vs-actual", response_model=List[BudgetVsActual])
def get_budget_vs_actual(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    rows = (
        db.query(
            Project.name,
            sqlfunc.coalesce(sqlfunc.sum(CBS.budget_cost), 0),
            sqlfunc.coalesce(sqlfunc.sum(CBS.actual_cost), 0),
            sqlfunc.coalesce(sqlfunc.sum(CBS.forecast_cost), 0),
        )
        .outerjoin(CBS, CBS.project_id == Project.id)
        .group_by(Project.id, Project.name)
        .all()
    )
    return [
        BudgetVsActual(
            project_name=name,
            budget=float(b),
            actual=float(a),
            forecast=float(f),
            variance=float(b) - float(a),
        )
        for name, b, a, f in rows
    ]


@router.get("/cashflow", response_model=List[CashflowItem])
def get_cashflow(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payments = (
        db.query(MilestonePayment)
        .join(Milestone, MilestonePayment.milestone_id == Milestone.id)
        .all()
    )

    monthly: dict[str, dict] = {}
    for p in payments:
        milestone = db.query(Milestone).filter(Milestone.id == p.milestone_id).first()
        if not milestone:
            continue
        month_key = milestone.planned_date.strftime("%Y-%m")
        if month_key not in monthly:
            monthly[month_key] = {"expected": 0, "received": 0}
        monthly[month_key]["expected"] += float(p.payment_value)
        if p.payment_status == "Received":
            monthly[month_key]["received"] += float(p.payment_value)

    return [
        CashflowItem(month=k, expected=v["expected"], received=v["received"])
        for k, v in sorted(monthly.items())
    ]


@router.get("/portfolio-health", response_model=List[PortfolioHealth])
def get_portfolio_health(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Per-project health summary with RAG indicators."""
    projects = db.query(Project).all()
    result = []
    for p in projects:
        activities = db.query(ProjectActivity).filter(ProjectActivity.project_id == p.id).all()
        spi = _compute_spi(activities)

        cbs_row = db.query(
            sqlfunc.coalesce(sqlfunc.sum(CBS.budget_cost), 0),
            sqlfunc.coalesce(sqlfunc.sum(CBS.actual_cost), 0),
        ).filter(CBS.project_id == p.id).first()
        budget = float(cbs_row[0])
        actual = float(cbs_row[1])
        proj_avg_completion = float(db.query(
            sqlfunc.coalesce(sqlfunc.avg(ProjectActivity.completion_pct), 0)
        ).filter(ProjectActivity.project_id == p.id).scalar())
        cpi = _compute_cpi(budget, actual, proj_avg_completion)

        risk_count = db.query(Risk).filter(Risk.project_id == p.id, Risk.status == "Open").count()
        risk_level = "Green" if risk_count <= 2 else ("Amber" if risk_count <= 5 else "Red")

        # LD exposure for this project
        ld_exp = 0.0
        if p.contract_completion_date and not p.actual_completion_date:
            delay = (date.today() - p.contract_completion_date).days
            if delay > 0:
                ld = delay * float(p.daily_ld_rate or 0)
                cap = float(p.contract_value or 0) * float(p.ld_cap_pct or 10) / 100
                ld_exp = min(ld, cap) if cap > 0 else ld

        schedule_rag = _rag_status(spi)
        cost_rag = _rag_status(cpi)

        overall = "Green"
        if schedule_rag == "Red" or cost_rag == "Red" or risk_level == "Red":
            overall = "Red"
        elif schedule_rag == "Amber" or cost_rag == "Amber" or risk_level == "Amber":
            overall = "Amber"

        result.append(PortfolioHealth(
            project_id=p.id,
            project_name=p.name,
            schedule_health=schedule_rag,
            cost_health=cost_rag,
            risk_level=risk_level,
            overall_status=overall,
            spi=spi,
            cpi=cpi,
            ld_exposure=round(ld_exp, 2),
        ))
    return result


@router.get("/planned-vs-actual", response_model=List[PlannedVsActualItem])
def get_planned_vs_actual(
    project_id: int | None = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Monthly aggregate planned vs actual cost with project names per point."""
    from dateutil.relativedelta import relativedelta

    if project_id:
        projects = db.query(Project).filter(Project.id == project_id).all()
    else:
        projects = db.query(Project).all()
    if not projects:
        return []

    all_starts = [p.start_date for p in projects if p.start_date]
    all_ends = [p.end_date for p in projects if p.end_date]
    if not all_starts or not all_ends:
        return []

    timeline_start = min(all_starts).replace(day=1)
    timeline_end = max(all_ends).replace(day=1)
    today = date.today().replace(day=1)

    # Generate month list
    months = []
    current = timeline_start
    while current <= timeline_end:
        months.append(current.strftime("%Y-%m"))
        current += relativedelta(months=1)

    # Per-project cost data
    project_costs = []
    for p in projects:
        cbs_row = db.query(
            sqlfunc.coalesce(sqlfunc.sum(CBS.budget_cost), 0),
            sqlfunc.coalesce(sqlfunc.sum(CBS.actual_cost), 0),
        ).filter(CBS.project_id == p.id).first()
        budget = float(cbs_row[0]) or float(p.total_budget or 0)
        actual = float(cbs_row[1])
        project_costs.append({
            "name": p.name,
            "budget": budget,
            "actual": actual,
            "start": p.start_date,
            "end": p.end_date,
        })

    # Build monthly aggregated data
    result = []
    for month_str in months:
        month_date = date.fromisoformat(f"{month_str}-01")
        total_planned = 0.0
        total_actual = 0.0
        active_projects = []

        for pc in project_costs:
            if not pc["start"] or not pc["end"]:
                continue
            proj_start = pc["start"].replace(day=1)
            proj_end = pc["end"].replace(day=1)
            if month_date < proj_start or month_date > proj_end:
                continue

            active_projects.append(pc["name"])
            total_months = max(
                (proj_end.year - proj_start.year) * 12 + proj_end.month - proj_start.month, 1
            )
            elapsed = (month_date.year - proj_start.year) * 12 + month_date.month - proj_start.month + 1

            total_planned += pc["budget"] * min(elapsed / total_months, 1.0)

            if month_date <= today:
                months_to_today = max(
                    (today.year - proj_start.year) * 12 + today.month - proj_start.month + 1, 1
                )
                total_actual += pc["actual"] * min(elapsed / months_to_today, 1.0)

        if active_projects:
            result.append(PlannedVsActualItem(
                month=month_str,
                planned=round(total_planned, 2),
                actual=round(total_actual, 2) if month_date <= today else None,
                projects=active_projects,
            ))

    return result


@router.get("/risk-heatmap", response_model=List[RiskHeatmapCell])
def get_risk_heatmap(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Portfolio-wide risk heatmap."""
    risks = db.query(Risk).filter(Risk.status == "Open").all()
    grid = {}
    for r in risks:
        key = (r.probability, r.impact)
        if key not in grid:
            grid[key] = {"probability": r.probability, "impact": r.impact, "count": 0, "risk_ids": []}
        grid[key]["count"] += 1
        grid[key]["risk_ids"].append(r.id)
    return list(grid.values())


@router.get("/delayed-milestones", response_model=List[DelayedMilestoneItem])
def get_delayed_milestones(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """Milestones that completed late (actual_date > planned_date)."""
    rows = (
        db.query(Milestone, Project.name)
        .join(Project, Milestone.project_id == Project.id)
        .filter(Milestone.actual_date.isnot(None))
        .all()
    )
    result = []
    for m, pname in rows:
        if m.status == "Delayed":
            result.append(DelayedMilestoneItem(
                id=m.id,
                project_name=pname,
                milestone_name=m.name,
                planned_date=m.planned_date.isoformat(),
                actual_date=m.actual_date.isoformat(),
                delay_days=m.delay_days,
                is_critical=m.is_critical,
            ))
    return result


@router.get("/open-risks", response_model=List[OpenRiskItem])
def get_open_risks(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    """All open risks across the portfolio."""
    risks = (
        db.query(Risk, Project.name)
        .join(Project, Risk.project_id == Project.id)
        .filter(Risk.status == "Open")
        .order_by(Risk.probability.desc(), Risk.impact.desc())
        .all()
    )
    return [
        OpenRiskItem(
            id=r.id,
            project_name=pname,
            risk_code=r.risk_code,
            title=r.title,
            category=r.category,
            probability=r.probability,
            impact=r.impact,
            risk_score=r.risk_score,
            owner=r.owner,
            status=r.status,
        )
        for r, pname in risks
    ]
