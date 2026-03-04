from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.compensation_event import CompensationEvent
from app.models.user import User
from app.schemas.compensation_event import (
    CompensationEventCreate,
    CompensationEventOut,
    CompensationEventUpdate,
)
from app.services.audit import log_action

router = APIRouter(prefix="/api/compensation-events", tags=["compensation_events"])


@router.get("/", response_model=List[CompensationEventOut])
def list_events(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(CompensationEvent)
    if project_id:
        query = query.filter(CompensationEvent.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{event_id}", response_model=CompensationEventOut)
def get_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    event = db.query(CompensationEvent).filter(CompensationEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Compensation event not found")
    return event


@router.post("/", response_model=CompensationEventOut, status_code=201)
def create_event(
    payload: CompensationEventCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    event = CompensationEvent(**payload.model_dump())
    db.add(event)
    db.commit()
    db.refresh(event)
    log_action(db, current_user.id, "CREATE", "CompensationEvent", event.id, event.event_name)
    return event


@router.put("/{event_id}", response_model=CompensationEventOut)
def update_event(
    event_id: int,
    payload: CompensationEventUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    event = db.query(CompensationEvent).filter(CompensationEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Compensation event not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(event, key, value)
    db.commit()
    db.refresh(event)
    log_action(db, current_user.id, "UPDATE", "CompensationEvent", event.id, event.event_name)
    return event


@router.delete("/{event_id}", status_code=204)
def delete_event(
    event_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    event = db.query(CompensationEvent).filter(CompensationEvent.id == event_id).first()
    if not event:
        raise HTTPException(status_code=404, detail="Compensation event not found")
    log_action(db, current_user.id, "DELETE", "CompensationEvent", event.id, event.event_name)
    db.delete(event)
    db.commit()
