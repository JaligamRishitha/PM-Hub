"""
Reports API — computes all 4 project report types server-side.

Endpoints:
  GET /api/reports/{project_id}/overall        → Overall Project Report
  GET /api/reports/{project_id}/milestones      → Key Milestone Report
  GET /api/reports/{project_id}/earned-value    → Earned Value Report
  GET /api/reports/{project_id}/issues-risks    → Issues / Risk Report
"""

from datetime import date, timedelta
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.activity import ProjectActivity
from app.models.cbs import CBS
from app.models.issue import Issue
from app.models.milestone import Milestone
from app.models.project import Project
from app.models.risk import Risk
from app.models.variation import ApprovedVariation
from app.models.user import User
from app.schemas.reports import (
    EVMetrics,
    EarnedValueReportResponse,
    FinancialSummary,
    IssueItem,
    IssueStatusCount,
    IssuePriorityCount,
    IssueSummary,
    IssuesRiskReportResponse,
    KeyMilestoneReportResponse,
    MilestoneReportItem,
    MilestoneReportSummary,
    MilestoneStatusDistribution,
    MilestoneSummary,
    MilestoneSummaryItem,
    OverallProjectReportResponse,
    RiskCategoryCount,
    RiskHeatmapCell,
    RiskItem,
    RiskSummary,
    SCurvePoint,
    ScheduleSummary,
    VarianceTrendPoint,
)

router = APIRouter(prefix="/api/reports", tags=["reports"])


# ─── Helpers ────────────────────────────────────────────────────────────

def _get_project_or_404(db: Session, project_id: int) -> Project:
    project = db.query(Project).filter(Project.id == project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")
    return project


def _compute_ev(project: Project, activities: list, cbs_items: list) -> EVMetrics:
    """Port of the frontend computeEV function."""
    bac = float(project.total_budget or 0)
    ac = sum(float(c.actual_cost or 0) for c in cbs_items)

    total_planned = 0.0
    total_earned = 0.0
    for a in activities:
        dur = max((a.planned_finish - a.planned_start).days, 1)
        total_planned += dur
        total_earned += dur * (float(a.completion_pct or 0) / 100.0)

    spi = round(total_earned / total_planned, 3) if total_planned > 0 else 1.0
    cpi = round(bac / ac, 3) if ac > 0 else 1.0

    overall_completion = total_earned / total_planned if total_planned > 0 else 0.0
    pv = round(bac * overall_completion) if total_planned > 0 else 0
    ev = round(bac * overall_completion)

    cv = ev - ac
    sv = ev - pv
    eac = round(bac / cpi) if cpi > 0 else bac
    vac = bac - eac

    return EVMetrics(
        bac=bac, pv=pv, ev=ev, ac=ac,
        cv=cv, sv=sv, cpi=cpi, spi=spi,
        eac=eac, vac=vac,
        overall_completion=round(overall_completion, 4),
    )


def _generate_s_curve(project: Project, activities: list, cbs_items: list) -> List[SCurvePoint]:
    """Port of the frontend generateTimePhasedEV function."""
    if not project or not activities:
        return []

    start_date = project.start_date
    end_date = project.end_date or project.contract_completion_date or date.today()
    bac = float(project.total_budget or 0)
    total_actual = sum(float(c.actual_cost or 0) for c in cbs_items)
    today = date.today()

    # Build monthly buckets
    months = []
    d = date(start_date.year, start_date.month, 1)
    last = max(end_date, today)
    while d <= last:
        months.append(d)
        if d.month == 12:
            d = date(d.year + 1, 1, 1)
        else:
            d = date(d.year, d.month + 1, 1)

    if not months:
        return []

    total_duration = max((end_date - start_date).days, 1)
    months_up_to_now = [m for m in months if m <= today]
    months_up_to_now_count = max(len(months_up_to_now), 1)

    result = []
    for idx, m in enumerate(months):
        # month end = last day of month
        if m.month == 12:
            month_end = date(m.year, 12, 31)
        else:
            month_end = date(m.year, m.month + 1, 1) - timedelta(days=1)

        elapsed = max((min(month_end, end_date) - start_date).days, 0)
        ratio = min(elapsed / total_duration, 1.0)
        pv_val = round(bac * ratio)

        # EV based on activity completion
        earned_days = 0.0
        planned_days = 0.0
        for a in activities:
            a_finish = a.planned_finish
            a_start = a.planned_start
            dur = max((a_finish - a_start).days, 1)
            planned_days += dur
            if month_end >= today:
                earned_days += dur * (float(a.completion_pct or 0) / 100.0)
            elif a_finish <= month_end:
                earned_days += dur
            elif a_start <= month_end:
                partial = min((month_end - a_start).days / dur, 1.0)
                earned_days += dur * min(partial, float(a.completion_pct or 0) / 100.0)

        ev_val = round(bac * (earned_days / planned_days)) if planned_days > 0 else 0

        # AC: linear spread of actual cost
        ac_val = None
        if month_end <= today:
            ac_ratio = min((idx + 1) / months_up_to_now_count, 1.0)
            ac_val = round(total_actual * ac_ratio)

        label = month_end.strftime("%b %y")
        result.append(SCurvePoint(month=label, PV=pv_val, EV=ev_val, AC=ac_val))

    return result


def _generate_variance_trend(
    project: Project, activities: list, cbs_items: list
) -> List[VarianceTrendPoint]:
    """Generate month-by-month CV and SV for the variance trend chart."""
    if not project or not activities:
        return []

    start_date = project.start_date
    end_date = project.end_date or project.contract_completion_date or date.today()
    bac = float(project.total_budget or 0)
    total_actual = sum(float(c.actual_cost or 0) for c in cbs_items)
    today = date.today()

    months = []
    d = date(start_date.year, start_date.month, 1)
    last = max(end_date, today)
    while d <= last:
        months.append(d)
        if d.month == 12:
            d = date(d.year + 1, 1, 1)
        else:
            d = date(d.year, d.month + 1, 1)

    if not months:
        return []

    total_duration = max((end_date - start_date).days, 1)
    months_up_to_now = [m for m in months if m <= today]
    months_up_to_now_count = max(len(months_up_to_now), 1)

    result = []
    for idx, m in enumerate(months):
        if m.month == 12:
            month_end = date(m.year, 12, 31)
        else:
            month_end = date(m.year, m.month + 1, 1) - timedelta(days=1)

        elapsed = max((min(month_end, end_date) - start_date).days, 0)
        ratio = min(elapsed / total_duration, 1.0)
        pv_val = bac * ratio

        earned_days = 0.0
        planned_days = 0.0
        for a in activities:
            dur = max((a.planned_finish - a.planned_start).days, 1)
            planned_days += dur
            if month_end >= today:
                earned_days += dur * (float(a.completion_pct or 0) / 100.0)
            elif a.planned_finish <= month_end:
                earned_days += dur
            elif a.planned_start <= month_end:
                partial = min((month_end - a.planned_start).days / dur, 1.0)
                earned_days += dur * min(partial, float(a.completion_pct or 0) / 100.0)

        ev_val = bac * (earned_days / planned_days) if planned_days > 0 else 0

        if month_end <= today:
            ac_ratio = min((idx + 1) / months_up_to_now_count, 1.0)
            ac_val = total_actual * ac_ratio
        else:
            ac_val = 0

        cv = round(ev_val - ac_val)
        sv = round(ev_val - pv_val)

        label = month_end.strftime("%b %y")
        result.append(VarianceTrendPoint(month=label, CV=cv, SV=sv))

    return result


# ─── 1. Overall Project Report ──────────────────────────────────────────

@router.get("/{project_id}/overall", response_model=OverallProjectReportResponse)
def get_overall_report(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    project = _get_project_or_404(db, project_id)
    activities = db.query(ProjectActivity).filter(
        ProjectActivity.project_id == project_id
    ).all()
    milestones_list = db.query(Milestone).filter(
        Milestone.project_id == project_id
    ).all()
    cbs_items = db.query(CBS).filter(CBS.project_id == project_id).all()
    variations = db.query(ApprovedVariation).filter(
        ApprovedVariation.project_id == project_id
    ).all()
    risks = db.query(Risk).filter(Risk.project_id == project_id).all()

    ev = _compute_ev(project, activities, cbs_items)
    s_curve = _generate_s_curve(project, activities, cbs_items)

    # Schedule summary
    total_acts = len(activities)
    completed_acts = sum(1 for a in activities if float(a.completion_pct or 0) >= 100)
    critical_acts = sum(1 for a in activities if a.is_critical)
    sched_variance_days = sum(a.delay_days for a in activities)

    # Financial summary
    approved_vars = sum(
        float(v.value or 0) for v in variations if v.approval_status == "Approved"
    )
    pending_vars = sum(
        float(v.value or 0)
        for v in variations
        if v.approval_status in ("Pending", "Under Review")
    )
    ld_rate = float(project.daily_ld_rate or 0)
    ld_exposure = sum(
        m.delay_days * ld_rate
        for m in milestones_list
        if m.delay_days > 0 and m.is_critical
    )
    forecast_margin = 0.0
    if project.contract_value and project.forecast_cost:
        cv_val = float(project.contract_value)
        fc_val = float(project.forecast_cost)
        forecast_margin = round((cv_val - fc_val) / cv_val * 100, 1) if cv_val else 0.0

    # Milestone summary
    today = date.today()
    in_30 = today + timedelta(days=30)
    total_ms = len(milestones_list)
    completed_ms = sum(1 for m in milestones_list if m.status == "Completed")
    delayed_ms = sum(1 for m in milestones_list if m.status == "Delayed")
    upcoming_ms = sum(
        1
        for m in milestones_list
        if m.planned_date >= today and m.planned_date <= in_30 and m.status != "Completed"
    )

    top_milestones = [
        MilestoneSummaryItem(
            name=m.name,
            planned_date=m.planned_date.isoformat(),
            delay_days=m.delay_days,
        )
        for m in milestones_list[:5]
    ]

    # Risk score
    total_risk_score = sum(
        r.probability * r.impact for r in risks if r.status != "Closed"
    )

    schedule_health_pct = min(round(ev.spi * 100), 100)
    cost_health_pct = min(round(ev.cpi * 100), 100)

    return OverallProjectReportResponse(
        project_name=project.name,
        client=project.client or "",
        contract_value=float(project.contract_value or 0),
        start_date=project.start_date.isoformat() if project.start_date else "",
        planned_finish=(
            (project.end_date or project.contract_completion_date or "").isoformat()
            if (project.end_date or project.contract_completion_date)
            else ""
        ),
        forecast_finish=(
            (project.actual_completion_date or project.end_date or "").isoformat()
            if (project.actual_completion_date or project.end_date)
            else ""
        ),
        data_date=today.strftime("%d/%m/%Y"),
        schedule_health_pct=schedule_health_pct,
        cost_health_pct=cost_health_pct,
        risk_score=total_risk_score,
        ld_exposure=ld_exposure,
        ev_metrics=ev,
        s_curve_data=s_curve,
        schedule_summary=ScheduleSummary(
            total_activities=total_acts,
            completed_activities=completed_acts,
            remaining_activities=total_acts - completed_acts,
            critical_activities=critical_acts,
            schedule_variance_days=sched_variance_days,
            spi=ev.spi,
        ),
        financial_summary=FinancialSummary(
            contract_value=float(project.contract_value or 0),
            budget_bac=float(project.total_budget or 0),
            actual_cost=ev.ac,
            approved_variations=approved_vars,
            pending_variations=pending_vars,
            ld_exposure=ld_exposure,
            forecast_margin_pct=forecast_margin,
        ),
        milestone_summary=MilestoneSummary(
            total=total_ms,
            completed=completed_ms,
            delayed=delayed_ms,
            upcoming_30_days=upcoming_ms,
            top_milestones=top_milestones,
        ),
    )


# ─── 2. Key Milestone Report ────────────────────────────────────────────

@router.get("/{project_id}/milestones", response_model=KeyMilestoneReportResponse)
def get_milestone_report(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    project = _get_project_or_404(db, project_id)
    milestones_list = db.query(Milestone).filter(
        Milestone.project_id == project_id
    ).all()

    total = len(milestones_list)
    completed = sum(1 for m in milestones_list if m.status == "Completed")
    delayed = sum(1 for m in milestones_list if m.status == "Delayed")
    critical = sum(1 for m in milestones_list if m.is_critical)
    delays = [m.delay_days for m in milestones_list if m.delay_days > 0]
    avg_delay = round(sum(delays) / len(delays), 1) if delays else 0.0

    # Status distribution
    status_counts: dict[str, int] = {}
    for m in milestones_list:
        s = m.status
        status_counts[s] = status_counts.get(s, 0) + 1

    items = [
        MilestoneReportItem(
            id=m.id,
            name=m.name,
            phase=m.phase or "",
            planned_date=m.planned_date.isoformat(),
            actual_date=m.actual_date.isoformat() if m.actual_date else None,
            status=m.status,
            is_critical=m.is_critical,
            delay_days=m.delay_days,
        )
        for m in milestones_list
    ]

    return KeyMilestoneReportResponse(
        project_start_date=project.start_date.isoformat() if project.start_date else "",
        summary=MilestoneReportSummary(
            total=total,
            completed=completed,
            delayed=delayed,
            critical=critical,
            avg_delay_days=avg_delay,
        ),
        status_distribution=[
            MilestoneStatusDistribution(status=k, count=v)
            for k, v in status_counts.items()
        ],
        milestones=items,
    )


# ─── 3. Earned Value Report ─────────────────────────────────────────────

@router.get("/{project_id}/earned-value", response_model=EarnedValueReportResponse)
def get_earned_value_report(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    project = _get_project_or_404(db, project_id)
    activities = db.query(ProjectActivity).filter(
        ProjectActivity.project_id == project_id
    ).all()
    cbs_items = db.query(CBS).filter(CBS.project_id == project_id).all()

    ev = _compute_ev(project, activities, cbs_items)
    s_curve = _generate_s_curve(project, activities, cbs_items)
    variance_trend = _generate_variance_trend(project, activities, cbs_items)

    return EarnedValueReportResponse(
        ev_metrics=ev,
        s_curve_data=s_curve,
        variance_trend=variance_trend,
    )


# ─── 4. Issues / Risk Report ────────────────────────────────────────────

@router.get("/{project_id}/issues-risks", response_model=IssuesRiskReportResponse)
def get_issues_risk_report(
    project_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    _get_project_or_404(db, project_id)
    risks = db.query(Risk).filter(Risk.project_id == project_id).all()
    issues_list = db.query(Issue).filter(Issue.project_id == project_id).all()

    # --- Risk summary ---
    open_risks = [r for r in risks if r.status != "Closed"]
    closed_risks = [r for r in risks if r.status == "Closed"]
    total_open = len(open_risks)
    total_closed = len(closed_risks)
    avg_score = (
        round(sum(r.risk_score for r in open_risks) / total_open, 1)
        if total_open
        else 0.0
    )
    total_exposure = sum(float(r.cost_exposure or 0) for r in open_risks)

    # Top 5 risks by score
    sorted_risks = sorted(open_risks, key=lambda r: r.risk_score, reverse=True)[:5]
    top_risks = [
        RiskItem(
            id=r.id,
            risk_code=r.risk_code,
            title=r.title,
            category=r.category,
            probability=r.probability,
            impact=r.impact,
            risk_score=r.risk_score,
            owner=r.owner,
            status=r.status,
            cost_exposure=float(r.cost_exposure or 0),
            mitigation_plan=r.mitigation_plan,
        )
        for r in sorted_risks
    ]

    # Heatmap
    heatmap_grid: dict[tuple, int] = {}
    for r in open_risks:
        key = (r.probability, r.impact)
        heatmap_grid[key] = heatmap_grid.get(key, 0) + 1
    heatmap = [
        RiskHeatmapCell(probability=k[0], impact=k[1], count=v)
        for k, v in heatmap_grid.items()
    ]

    # Categories
    cat_counts: dict[str, int] = {}
    for r in open_risks:
        cat = r.category or "Uncategorized"
        cat_counts[cat] = cat_counts.get(cat, 0) + 1
    categories = [
        RiskCategoryCount(category=k, count=v) for k, v in cat_counts.items()
    ]

    # --- Issue summary ---
    total_issues = len(issues_list)
    open_issues = sum(1 for i in issues_list if i.status == "Open")
    in_progress_issues = sum(1 for i in issues_list if i.status == "In Progress")
    resolved_issues = sum(
        1 for i in issues_list if i.status in ("Resolved", "Closed")
    )
    overdue_issues = sum(1 for i in issues_list if i.is_overdue)

    # Status breakdown
    issue_status_counts: dict[str, int] = {}
    for i in issues_list:
        s = i.status or "Open"
        issue_status_counts[s] = issue_status_counts.get(s, 0) + 1

    # Priority breakdown
    issue_priority_counts: dict[str, int] = {}
    for i in issues_list:
        p = i.priority or "Medium"
        issue_priority_counts[p] = issue_priority_counts.get(p, 0) + 1

    issue_items = [
        IssueItem(
            id=i.id,
            issue_code=i.issue_code,
            title=i.title,
            priority=i.priority or "Medium",
            status=i.status or "Open",
            assigned_to=i.assigned_to,
            raised_date=i.raised_date.isoformat() if i.raised_date else None,
            due_date=i.due_date.isoformat() if i.due_date else None,
            is_overdue=i.is_overdue,
        )
        for i in issues_list
    ]

    # All risks for the table
    all_risk_items = [
        RiskItem(
            id=r.id,
            risk_code=r.risk_code,
            title=r.title,
            category=r.category,
            probability=r.probability,
            impact=r.impact,
            risk_score=r.risk_score,
            owner=r.owner,
            status=r.status,
            cost_exposure=float(r.cost_exposure or 0),
            mitigation_plan=r.mitigation_plan,
        )
        for r in risks
    ]

    return IssuesRiskReportResponse(
        risk_summary=RiskSummary(
            total_open=total_open,
            total_closed=total_closed,
            avg_risk_score=avg_score,
            total_cost_exposure=total_exposure,
            top_risks=top_risks,
            heatmap=heatmap,
            categories=categories,
        ),
        risks=all_risk_items,
        issues=issue_items,
        issue_summary=IssueSummary(
            total=total_issues,
            open_count=open_issues,
            in_progress=in_progress_issues,
            resolved=resolved_issues,
            overdue=overdue_issues,
            status_breakdown=[
                IssueStatusCount(status=k, count=v)
                for k, v in issue_status_counts.items()
            ],
            priority_breakdown=[
                IssuePriorityCount(priority=k, count=v)
                for k, v in issue_priority_counts.items()
            ],
        ),
    )
