import json
from datetime import timedelta
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.activity import ProjectActivity
from app.models.cbs import CBS
from app.models.milestone import Milestone
from app.models.milestone_payment import MilestonePayment
from app.models.project import Project
from app.models.simulation import SimulationScenario, SimulationSession
from app.models.user import User
from app.schemas.simulation import (
    SimulationRunRequest,
    SimulationScenarioOut,
    SimulationSessionCreate,
    SimulationSessionDetail,
    SimulationSessionOut,
)
from app.services.audit import log_action
from app.services.simulation_engine import run_simulation

router = APIRouter(prefix="/api/simulation", tags=["simulation"])


# ---- helpers ----
def _parse_json(text: str) -> dict:
    try:
        return json.loads(text)
    except (json.JSONDecodeError, TypeError):
        return {}


def _scenario_to_out(s: SimulationScenario) -> SimulationScenarioOut:
    return SimulationScenarioOut(
        id=s.id,
        simulation_session_id=s.simulation_session_id,
        type=s.type,
        input_parameters=_parse_json(s.input_parameters),
        output_results=_parse_json(s.output_results),
        created_at=s.created_at,
    )


def _session_to_detail(s: SimulationSession) -> SimulationSessionDetail:
    return SimulationSessionDetail(
        id=s.id,
        project_id=s.project_id,
        created_by=s.created_by,
        name=s.name,
        status=s.status,
        created_at=s.created_at,
        scenarios=[_scenario_to_out(sc) for sc in s.scenarios],
    )


# ---- endpoints ----
@router.post("/start", response_model=SimulationSessionOut, status_code=201)
def start_session(
    payload: SimulationSessionCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    project = db.query(Project).filter(Project.id == payload.project_id).first()
    if not project:
        raise HTTPException(status_code=404, detail="Project not found")

    session = SimulationSession(
        project_id=payload.project_id,
        created_by=current_user.id,
        name=payload.name,
        status="Draft",
    )
    db.add(session)
    db.commit()
    db.refresh(session)
    return session


@router.post("/run", response_model=SimulationScenarioOut)
def run_scenario(
    payload: SimulationRunRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = (
        db.query(SimulationSession)
        .filter(
            SimulationSession.id == payload.session_id,
            SimulationSession.created_by == current_user.id,
        )
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Simulation session not found")
    if session.status != "Draft":
        raise HTTPException(status_code=400, detail="Session is not in Draft status")

    # Run simulation (in-memory, no real data changed)
    try:
        results = run_simulation(db, session.project_id, payload.type, payload.input_parameters)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

    scenario = SimulationScenario(
        simulation_session_id=session.id,
        type=payload.type,
        input_parameters=json.dumps(payload.input_parameters),
        output_results=json.dumps(results),
    )
    db.add(scenario)
    db.commit()
    db.refresh(scenario)
    return _scenario_to_out(scenario)


@router.get("/sessions", response_model=List[SimulationSessionOut])
def list_sessions(
    project_id: int = None,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(SimulationSession).filter(
        SimulationSession.created_by == current_user.id
    )
    if project_id:
        query = query.filter(SimulationSession.project_id == project_id)
    return query.order_by(SimulationSession.created_at.desc()).all()


@router.get("/{session_id}", response_model=SimulationSessionDetail)
def get_session(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = (
        db.query(SimulationSession)
        .filter(
            SimulationSession.id == session_id,
            SimulationSession.created_by == current_user.id,
        )
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    return _session_to_detail(session)


@router.post("/{session_id}/apply")
def apply_simulation(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = (
        db.query(SimulationSession)
        .filter(
            SimulationSession.id == session_id,
            SimulationSession.created_by == current_user.id,
        )
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    if session.status != "Draft":
        raise HTTPException(status_code=400, detail="Only Draft sessions can be applied")

    project = db.query(Project).filter(Project.id == session.project_id).first()
    if project.status == "Completed":
        raise HTTPException(status_code=400, detail="Cannot apply simulation to a closed project")

    # Apply each scenario's effects to real data
    for scenario in session.scenarios:
        params = _parse_json(scenario.input_parameters)
        results = _parse_json(scenario.output_results)

        if scenario.type == "Schedule":
            delay_days = int(params.get("delay_days", 0))
            delta = timedelta(days=delay_days)
            target_milestone_id = params.get("milestone_id")
            target_phase = params.get("phase")

            milestones = db.query(Milestone).filter(Milestone.project_id == session.project_id).all()
            for m in milestones:
                apply = False
                if target_milestone_id and m.id == int(target_milestone_id):
                    apply = True
                elif target_phase and m.phase == target_phase:
                    apply = True
                elif not target_milestone_id and not target_phase:
                    apply = True
                if apply and not m.actual_date:
                    m.planned_date = m.planned_date + delta

            activities = db.query(ProjectActivity).filter(ProjectActivity.project_id == session.project_id).all()
            for a in activities:
                apply = False
                if target_phase and a.phase == target_phase:
                    apply = True
                elif not target_milestone_id and not target_phase:
                    apply = True
                if apply:
                    a.planned_start = a.planned_start + delta
                    a.planned_finish = a.planned_finish + delta

            if results.get("simulated_end_date"):
                from datetime import date
                project.end_date = date.fromisoformat(results["simulated_end_date"])
            if results.get("project_status_after"):
                project.status = results["project_status_after"]

        elif scenario.type == "Cost":
            # Update CBS actuals proportionally
            after_cbs = results.get("after_cbs", [])
            for item in after_cbs:
                cbs = db.query(CBS).filter(CBS.id == item["id"]).first()
                if cbs:
                    cbs.actual_cost = item["actual_cost"]

        elif scenario.type == "LD":
            # LD is informational; optionally update project LD rate
            if params.get("daily_ld_rate"):
                project.daily_ld_rate = float(params["daily_ld_rate"])

    session.status = "Applied"
    db.commit()

    log_action(
        db,
        current_user.id,
        "APPLY_SIMULATION",
        "SimulationSession",
        session.id,
        f"Applied simulation '{session.name}' to project {session.project_id}",
    )

    return {"detail": "Simulation applied successfully", "session_id": session.id}


@router.post("/{session_id}/discard")
def discard_simulation(
    session_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    session = (
        db.query(SimulationSession)
        .filter(
            SimulationSession.id == session_id,
            SimulationSession.created_by == current_user.id,
        )
        .first()
    )
    if not session:
        raise HTTPException(status_code=404, detail="Session not found")
    if session.status != "Draft":
        raise HTTPException(status_code=400, detail="Only Draft sessions can be discarded")

    session.status = "Discarded"
    db.commit()
    return {"detail": "Simulation discarded", "session_id": session.id}
