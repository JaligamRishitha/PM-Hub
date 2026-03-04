from datetime import date, timedelta
from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.hse_checklist import HSEChecklist
from app.models.milestone import Milestone
from app.models.project import Project
from app.models.user import User
from app.schemas.milestone import MilestoneCreate, MilestoneOut, MilestoneUpdate
from app.services.audit import log_action

router = APIRouter(prefix="/api/milestones", tags=["milestones"])


@router.get("/", response_model=List[MilestoneOut])
def list_milestones(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(Milestone)
    if project_id:
        query = query.filter(Milestone.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/upcoming", response_model=List[MilestoneOut])
def upcoming_milestones(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    today = date.today()
    week_later = today + timedelta(days=7)
    return (
        db.query(Milestone)
        .filter(
            Milestone.planned_date >= today,
            Milestone.planned_date <= week_later,
            Milestone.actual_date.is_(None),
        )
        .all()
    )


@router.get("/{milestone_id}", response_model=MilestoneOut)
def get_milestone(
    milestone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    milestone = db.query(Milestone).filter(Milestone.id == milestone_id).first()
    if not milestone:
        raise HTTPException(status_code=404, detail="Milestone not found")
    return milestone


@router.post("/", response_model=MilestoneOut, status_code=201)
def create_milestone(
    payload: MilestoneCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    milestone = Milestone(**payload.model_dump())
    db.add(milestone)
    db.commit()
    db.refresh(milestone)
    log_action(db, current_user.id, "CREATE", "Milestone", milestone.id, milestone.name)
    return milestone


@router.put("/{milestone_id}", response_model=MilestoneOut)
def update_milestone(
    milestone_id: int,
    payload: MilestoneUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    milestone = db.query(Milestone).filter(Milestone.id == milestone_id).first()
    if not milestone:
        raise HTTPException(status_code=404, detail="Milestone not found")

    # Business logic: Mechanical Completion cannot be marked complete
    # unless all HSE checklist items are completed
    if (
        payload.actual_date is not None
        and "mechanical completion" in milestone.name.lower()
    ):
        incomplete = (
            db.query(HSEChecklist)
            .filter(
                HSEChecklist.project_id == milestone.project_id,
                HSEChecklist.status != "Completed",
            )
            .count()
        )
        if incomplete > 0:
            raise HTTPException(
                status_code=400,
                detail=f"Cannot complete Mechanical Completion: {incomplete} HSE checklist item(s) still pending",
            )

    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(milestone, key, value)
    db.commit()
    db.refresh(milestone)

    # If a critical milestone is delayed, mark project as At Risk
    if milestone.is_critical and milestone.status == "Delayed":
        project = db.query(Project).filter(Project.id == milestone.project_id).first()
        if project and project.status != "At Risk":
            project.status = "At Risk"
            db.commit()

    log_action(db, current_user.id, "UPDATE", "Milestone", milestone.id, milestone.name)
    return milestone


@router.delete("/{milestone_id}", status_code=204)
def delete_milestone(
    milestone_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    milestone = db.query(Milestone).filter(Milestone.id == milestone_id).first()
    if not milestone:
        raise HTTPException(status_code=404, detail="Milestone not found")
    log_action(db, current_user.id, "DELETE", "Milestone", milestone.id, milestone.name)
    db.delete(milestone)
    db.commit()
