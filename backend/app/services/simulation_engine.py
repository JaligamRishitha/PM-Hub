"""
Simulation Engine — all calculations run on cloned in-memory data.
Nothing is persisted to real project tables until explicitly applied.
"""
from datetime import timedelta
from typing import Any, Dict

from sqlalchemy.orm import Session

from app.models.cbs import CBS
from app.models.milestone import Milestone
from app.models.milestone_payment import MilestonePayment
from app.models.project import Project
from app.models.activity import ProjectActivity


PHASE_ORDER = ["Pre Gate B", "Gate B-C", "Gate C-D", "Closure"]


def _phase_index(phase_name: str) -> int:
    """Return ordinal index of a phase.  Unknown phases sort after Closure."""
    try:
        return PHASE_ORDER.index(phase_name)
    except ValueError:
        return len(PHASE_ORDER)


def run_schedule_simulation(db: Session, project_id: int, params: Dict[str, Any]) -> Dict[str, Any]:
    """Simulate adding delay to a milestone or an entire phase.

    Cascading logic — phase-aware dependency chain:
      1. Identify the *trigger phase* (the phase of the selected milestone
         or the directly-selected phase).
      2. Every milestone / activity in the trigger phase **and all
         subsequent phases** is shifted forward by the delay.
      3. A per-phase cascade breakdown is returned so the UI can show the
         ripple effect across the project lifecycle.
    """
    project = db.query(Project).filter(Project.id == project_id).first()
    milestones = db.query(Milestone).filter(Milestone.project_id == project_id).all()
    activities = db.query(ProjectActivity).filter(ProjectActivity.project_id == project_id).all()

    delay_days = int(params.get("delay_days", 0))
    target_milestone_id = params.get("milestone_id")
    target_phase = params.get("phase")
    delta = timedelta(days=delay_days)

    # ── Determine trigger phase ──
    trigger_phase = None
    if target_milestone_id:
        for m in milestones:
            if m.id == int(target_milestone_id):
                trigger_phase = m.phase
                break
    elif target_phase:
        trigger_phase = target_phase

    trigger_idx = _phase_index(trigger_phase) if trigger_phase else 0

    # Collect all phases actually present in the project (ordered)
    project_phases = sorted(
        {a.phase for a in activities if a.phase},
        key=_phase_index,
    )

    # Phases that will be affected (trigger phase + everything after)
    affected_phases = set()
    for ph in project_phases:
        if _phase_index(ph) >= trigger_idx:
            affected_phases.add(ph)

    def _should_shift_milestone(m):
        """Decide if a milestone should be shifted."""
        if trigger_phase is None:
            return True  # No target → delay everything
        if target_milestone_id:
            # Shift the target milestone + everything in its phase and later phases
            return (m.phase in affected_phases) if m.phase else (m.planned_date >= _cascade_date)
        return m.phase in affected_phases if m.phase else False

    def _should_shift_activity(a):
        """Decide if an activity should be shifted."""
        if trigger_phase is None:
            return True
        return a.phase in affected_phases if a.phase else False

    # Fallback cascade date for milestones without phase info
    _cascade_date = None
    if target_milestone_id:
        for m in milestones:
            if m.id == int(target_milestone_id):
                _cascade_date = m.planned_date
                break
    elif trigger_phase:
        phase_dates = [m.planned_date for m in milestones if m.phase == trigger_phase]
        if phase_dates:
            _cascade_date = min(phase_dates)

    # ── Build before / after milestone lists ──
    before_milestones = []
    after_milestones = []
    critical_impacted = False

    for m in milestones:
        before_row = {
            "id": m.id,
            "name": m.name,
            "phase": m.phase,
            "planned_date": m.planned_date.isoformat(),
            "actual_date": m.actual_date.isoformat() if m.actual_date else None,
            "is_critical": m.is_critical,
            "status": m.status,
            "delay_days": m.delay_days,
        }
        before_milestones.append(before_row)

        apply_delay = _should_shift_milestone(m)

        new_planned = m.planned_date + delta if apply_delay else m.planned_date
        new_actual = m.actual_date
        sim_delay = 0
        if new_actual and new_actual > new_planned:
            sim_delay = (new_actual - new_planned).days
        elif apply_delay and not new_actual:
            sim_delay = delay_days

        sim_status = m.status
        if apply_delay and not m.actual_date:
            sim_status = "Delayed" if delay_days > 0 else "Pending"

        if apply_delay and m.is_critical and delay_days > 0:
            critical_impacted = True

        after_milestones.append({
            **before_row,
            "planned_date": new_planned.isoformat(),
            "new_delay_days": sim_delay,
            "status": sim_status,
            "shifted": apply_delay,
        })

    # ── Build before / after activity lists ──
    before_activities = []
    after_activities = []
    for a in activities:
        before_row = {
            "id": a.id,
            "activity_name": a.activity_name,
            "phase": a.phase,
            "planned_start": a.planned_start.isoformat(),
            "planned_finish": a.planned_finish.isoformat(),
            "status": a.status,
        }
        before_activities.append(before_row)

        apply_delay = _should_shift_activity(a)

        after_activities.append({
            **before_row,
            "planned_start": (a.planned_start + delta).isoformat() if apply_delay else a.planned_start.isoformat(),
            "planned_finish": (a.planned_finish + delta).isoformat() if apply_delay else a.planned_finish.isoformat(),
            "shifted": apply_delay,
        })

    # ── Compute new project end date ──
    original_end = project.end_date
    new_end = original_end + delta if trigger_phase is None else original_end
    for am in after_milestones:
        import datetime
        d = datetime.date.fromisoformat(am["planned_date"])
        if d > new_end:
            new_end = d
    for aa in after_activities:
        import datetime
        d = datetime.date.fromisoformat(aa["planned_finish"])
        if d > new_end:
            new_end = d

    total_delay = delay_days
    project_status = "At Risk" if critical_impacted else project.status

    # ── Per-phase cascade breakdown ──
    # Shows which phases are impacted + counts of shifted items
    cascade_breakdown = []
    for ph in project_phases:
        is_affected = ph in affected_phases
        ph_milestones = [am for am in after_milestones if am.get("phase") == ph]
        ph_activities = [aa for aa in after_activities if aa.get("phase") == ph]
        shifted_m = sum(1 for m in ph_milestones if m.get("shifted"))
        shifted_a = sum(1 for a in ph_activities if a.get("shifted"))
        cascade_breakdown.append({
            "phase": ph,
            "phase_order": _phase_index(ph),
            "is_trigger": ph == trigger_phase,
            "is_affected": is_affected,
            "delay_days": delay_days if is_affected else 0,
            "milestones_total": len(ph_milestones),
            "milestones_shifted": shifted_m,
            "activities_total": len(ph_activities),
            "activities_shifted": shifted_a,
        })

    return {
        "project_name": project.name,
        "original_end_date": original_end.isoformat(),
        "simulated_end_date": new_end.isoformat(),
        "total_delay_days": total_delay,
        "critical_milestone_impacted": critical_impacted,
        "project_status_before": project.status,
        "project_status_after": project_status,
        "trigger_phase": trigger_phase,
        "affected_phases": list(affected_phases),
        "cascade_breakdown": cascade_breakdown,
        "before_milestones": before_milestones,
        "after_milestones": after_milestones,
        "before_activities": before_activities,
        "after_activities": after_activities,
    }


def run_cost_simulation(db: Session, project_id: int, params: Dict[str, Any]) -> Dict[str, Any]:
    """Simulate cost impact from schedule delays."""
    project = db.query(Project).filter(Project.id == project_id).first()
    cbs_items = db.query(CBS).filter(CBS.project_id == project_id).all()

    time_impact = int(params.get("time_impact_days", 0))
    daily_overhead = float(params.get("daily_overhead_cost", 0))
    escalation_pct = float(params.get("escalation_pct", 0))

    total_budget = sum(float(c.budget_cost or 0) for c in cbs_items)
    total_actual = sum(float(c.actual_cost or 0) for c in cbs_items)

    cost_impact = time_impact * daily_overhead
    escalation_amount = cost_impact * (escalation_pct / 100)
    total_cost_impact = cost_impact + escalation_amount

    forecast_cost = total_actual + total_cost_impact
    budget_variance = total_budget - forecast_cost
    cost_increase_pct = (total_cost_impact / total_actual * 100) if total_actual > 0 else 0

    before_cbs = []
    after_cbs = []
    for c in cbs_items:
        before_cbs.append({
            "id": c.id,
            "wbs_code": c.wbs_code,
            "description": c.description,
            "budget_cost": float(c.budget_cost or 0),
            "actual_cost": float(c.actual_cost or 0),
            "variance": c.variance,
        })
        # Distribute overhead proportionally across CBS items by actual cost
        proportion = float(c.actual_cost or 0) / total_actual if total_actual > 0 else 1 / len(cbs_items)
        item_impact = total_cost_impact * proportion
        sim_actual = float(c.actual_cost or 0) + item_impact
        after_cbs.append({
            "id": c.id,
            "wbs_code": c.wbs_code,
            "description": c.description,
            "budget_cost": float(c.budget_cost or 0),
            "actual_cost": round(sim_actual, 2),
            "variance": round(float(c.budget_cost or 0) - sim_actual - float(c.approved_variation or 0), 2),
            "cost_added": round(item_impact, 2),
        })

    return {
        "project_name": project.name,
        "time_impact_days": time_impact,
        "daily_overhead_cost": daily_overhead,
        "escalation_pct": escalation_pct,
        "cost_impact": round(cost_impact, 2),
        "escalation_amount": round(escalation_amount, 2),
        "total_cost_impact": round(total_cost_impact, 2),
        "total_budget": round(total_budget, 2),
        "current_actual_cost": round(total_actual, 2),
        "forecast_cost": round(forecast_cost, 2),
        "budget_variance": round(budget_variance, 2),
        "cost_increase_pct": round(cost_increase_pct, 2),
        "before_cbs": before_cbs,
        "after_cbs": after_cbs,
    }


def run_cashflow_simulation(db: Session, project_id: int, params: Dict[str, Any]) -> Dict[str, Any]:
    """Simulate cashflow impact from milestone delays."""
    project = db.query(Project).filter(Project.id == project_id).first()
    milestones = db.query(Milestone).filter(Milestone.project_id == project_id).all()

    delay_days = int(params.get("milestone_delay_days", 0))
    delta = timedelta(days=delay_days)

    before_cashflow = {}
    after_cashflow = {}

    for ms in milestones:
        payments = db.query(MilestonePayment).filter(MilestonePayment.milestone_id == ms.id).all()
        for p in payments:
            # Before: use planned date
            month_key = ms.planned_date.strftime("%Y-%m")
            if month_key not in before_cashflow:
                before_cashflow[month_key] = {"expected": 0, "received": 0}
            before_cashflow[month_key]["expected"] += float(p.payment_value)
            if p.payment_status == "Received":
                before_cashflow[month_key]["received"] += float(p.payment_value)

            # After: shift pending payments by delay
            if p.payment_status == "Received":
                # Already received — stays the same
                after_month = month_key
                if after_month not in after_cashflow:
                    after_cashflow[after_month] = {"expected": 0, "received": 0}
                after_cashflow[after_month]["expected"] += float(p.payment_value)
                after_cashflow[after_month]["received"] += float(p.payment_value)
            else:
                new_date = ms.planned_date + delta
                after_month = new_date.strftime("%Y-%m")
                if after_month not in after_cashflow:
                    after_cashflow[after_month] = {"expected": 0, "received": 0}
                after_cashflow[after_month]["expected"] += float(p.payment_value)

    # Build sorted timeline
    all_months = sorted(set(list(before_cashflow.keys()) + list(after_cashflow.keys())))

    before_series = []
    after_series = []
    cumulative_before = 0
    cumulative_after = 0
    max_gap = 0

    for m in all_months:
        b = before_cashflow.get(m, {"expected": 0, "received": 0})
        a = after_cashflow.get(m, {"expected": 0, "received": 0})
        cumulative_before += b["expected"]
        cumulative_after += a["expected"]
        gap = cumulative_before - cumulative_after
        if gap > max_gap:
            max_gap = gap
        before_series.append({"month": m, "expected": b["expected"], "received": b["received"], "cumulative": round(cumulative_before, 2)})
        after_series.append({"month": m, "expected": a["expected"], "received": a["received"], "cumulative": round(cumulative_after, 2)})

    # Combined for chart
    combined = []
    for m in all_months:
        b = before_cashflow.get(m, {"expected": 0, "received": 0})
        a = after_cashflow.get(m, {"expected": 0, "received": 0})
        combined.append({
            "month": m,
            "before_expected": b["expected"],
            "after_expected": a["expected"],
            "before_received": b["received"],
            "after_received": a["received"],
        })

    total_expected = sum(b["expected"] for b in before_cashflow.values())
    total_received = sum(b["received"] for b in before_cashflow.values())

    return {
        "project_name": project.name,
        "delay_days": delay_days,
        "total_expected": round(total_expected, 2),
        "total_received": round(total_received, 2),
        "working_capital_gap": round(max_gap, 2),
        "before_cashflow": before_series,
        "after_cashflow": after_series,
        "combined_chart": combined,
    }


def run_ld_simulation(db: Session, project_id: int, params: Dict[str, Any]) -> Dict[str, Any]:
    """Simulate liquidated damages from delays."""
    project = db.query(Project).filter(Project.id == project_id).first()
    cbs_items = db.query(CBS).filter(CBS.project_id == project_id).all()
    milestones = db.query(Milestone).filter(Milestone.project_id == project_id).all()

    delay_days = int(params.get("delay_days", 0))
    daily_ld_rate = float(params.get("daily_ld_rate") or project.daily_ld_rate or 0)

    total_budget = sum(float(c.budget_cost or 0) for c in cbs_items)
    total_actual = sum(float(c.actual_cost or 0) for c in cbs_items)

    # Current LD from already-delayed milestones
    existing_ld = 0
    milestone_details = []
    for m in milestones:
        existing_penalty = m.delay_days * float(project.daily_ld_rate or 0)
        existing_ld += existing_penalty
        sim_penalty = delay_days * daily_ld_rate
        milestone_details.append({
            "id": m.id,
            "name": m.name,
            "is_critical": m.is_critical,
            "current_delay_days": m.delay_days,
            "current_penalty": round(existing_penalty, 2),
            "simulated_additional_delay": delay_days,
            "simulated_penalty": round(sim_penalty, 2),
            "total_penalty": round(existing_penalty + sim_penalty, 2),
        })

    total_ld_penalty = delay_days * daily_ld_rate
    profit_before = total_budget - total_actual - existing_ld
    profit_after = profit_before - total_ld_penalty

    return {
        "project_name": project.name,
        "delay_days": delay_days,
        "daily_ld_rate": daily_ld_rate,
        "total_ld_penalty": round(total_ld_penalty, 2),
        "existing_ld": round(existing_ld, 2),
        "combined_ld": round(existing_ld + total_ld_penalty, 2),
        "total_budget": round(total_budget, 2),
        "total_actual_cost": round(total_actual, 2),
        "profit_before_ld": round(profit_before, 2),
        "profit_after_ld": round(profit_after, 2),
        "profit_impact_pct": round((total_ld_penalty / profit_before * 100) if profit_before > 0 else 0, 2),
        "milestone_details": milestone_details,
    }


def run_resource_simulation(db: Session, project_id: int, params: Dict[str, Any]) -> Dict[str, Any]:
    """Simulate accelerating an activity by adding resources."""
    project = db.query(Project).filter(Project.id == project_id).first()
    activities = db.query(ProjectActivity).filter(ProjectActivity.project_id == project_id).all()

    target_activity_id = int(params.get("activity_id", 0))
    additional_resources = int(params.get("additional_resources", 0))
    productivity_gain_pct = float(params.get("productivity_gain_pct", 15))

    total_gain = additional_resources * productivity_gain_pct
    # Cap at 60% total reduction
    total_gain = min(total_gain, 60)

    before_activities = []
    after_activities = []
    days_saved = 0

    for a in activities:
        duration = (a.planned_finish - a.planned_start).days
        before_row = {
            "id": a.id,
            "activity_name": a.activity_name,
            "phase": a.phase,
            "planned_start": a.planned_start.isoformat(),
            "planned_finish": a.planned_finish.isoformat(),
            "duration_days": duration,
            "completion_pct": float(a.completion_pct or 0),
            "status": a.status,
        }
        before_activities.append(before_row)

        if a.id == target_activity_id:
            remaining_pct = 100 - float(a.completion_pct or 0)
            remaining_days = int(duration * remaining_pct / 100)
            reduced_days = int(remaining_days * (1 - total_gain / 100))
            days_saved = remaining_days - reduced_days
            new_finish = a.planned_finish - timedelta(days=days_saved)

            after_activities.append({
                **before_row,
                "planned_finish": new_finish.isoformat(),
                "duration_days": (new_finish - a.planned_start).days,
                "days_saved": days_saved,
                "additional_resources": additional_resources,
                "accelerated": True,
            })
        else:
            after_activities.append({**before_row, "accelerated": False, "days_saved": 0})

    # Cost of additional resources (estimate: €500/day per resource)
    resource_cost_per_day = 500
    remaining_work_days = 0
    for a in activities:
        if a.id == target_activity_id:
            remaining_pct = 100 - float(a.completion_pct or 0)
            remaining_work_days = int((a.planned_finish - a.planned_start).days * remaining_pct / 100)
            break
    additional_cost = additional_resources * resource_cost_per_day * remaining_work_days

    return {
        "project_name": project.name,
        "target_activity_id": target_activity_id,
        "additional_resources": additional_resources,
        "productivity_gain_pct": productivity_gain_pct,
        "total_gain_pct": total_gain,
        "days_saved": days_saved,
        "additional_cost": round(additional_cost, 2),
        "cost_per_day_saved": round(additional_cost / days_saved, 2) if days_saved > 0 else 0,
        "before_activities": before_activities,
        "after_activities": after_activities,
    }


# --- Dispatcher ---
SIMULATION_RUNNERS = {
    "Schedule": run_schedule_simulation,
    "Cost": run_cost_simulation,
    "Cashflow": run_cashflow_simulation,
    "LD": run_ld_simulation,
    "Resource": run_resource_simulation,
}


def run_simulation(db: Session, project_id: int, sim_type: str, params: Dict[str, Any]) -> Dict[str, Any]:
    runner = SIMULATION_RUNNERS.get(sim_type)
    if not runner:
        raise ValueError(f"Unknown simulation type: {sim_type}")
    return runner(db, project_id, params)
