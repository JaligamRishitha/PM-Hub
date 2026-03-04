from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.activity import ProjectActivity
from app.models.user import User
from app.schemas.activity import ActivityCreate, ActivityOut, ActivityUpdate
from app.services.audit import log_action

router = APIRouter(prefix="/api/activities", tags=["activities"])


@router.get("/", response_model=List[ActivityOut])
def list_activities(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(ProjectActivity)
    if project_id:
        query = query.filter(ProjectActivity.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{activity_id}", response_model=ActivityOut)
def get_activity(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    activity = db.query(ProjectActivity).filter(ProjectActivity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    return activity


@router.post("/", response_model=ActivityOut, status_code=201)
def create_activity(
    payload: ActivityCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    activity = ProjectActivity(**payload.model_dump())
    db.add(activity)
    db.commit()
    db.refresh(activity)
    log_action(db, current_user.id, "CREATE", "Activity", activity.id, activity.activity_name)
    return activity


@router.put("/{activity_id}", response_model=ActivityOut)
def update_activity(
    activity_id: int,
    payload: ActivityUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    activity = db.query(ProjectActivity).filter(ProjectActivity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(activity, key, value)
    db.commit()
    db.refresh(activity)
    log_action(db, current_user.id, "UPDATE", "Activity", activity.id, activity.activity_name)
    return activity


@router.delete("/{activity_id}", status_code=204)
def delete_activity(
    activity_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    activity = db.query(ProjectActivity).filter(ProjectActivity.id == activity_id).first()
    if not activity:
        raise HTTPException(status_code=404, detail="Activity not found")
    log_action(db, current_user.id, "DELETE", "Activity", activity.id, activity.activity_name)
    db.delete(activity)
    db.commit()
