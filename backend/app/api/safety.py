from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.safety_incident import SafetyIncident
from app.models.user import User
from app.schemas.safety_incident import (
    SafetyIncidentCreate,
    SafetyIncidentOut,
    SafetyIncidentUpdate,
)
from app.services.audit import log_action

router = APIRouter(prefix="/api/safety-incidents", tags=["safety"])


@router.get("/", response_model=List[SafetyIncidentOut])
def list_incidents(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(SafetyIncident)
    if project_id:
        query = query.filter(SafetyIncident.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{incident_id}", response_model=SafetyIncidentOut)
def get_incident(
    incident_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = db.query(SafetyIncident).filter(SafetyIncident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return incident


@router.post("/", response_model=SafetyIncidentOut, status_code=201)
def create_incident(
    payload: SafetyIncidentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = SafetyIncident(**payload.model_dump())
    db.add(incident)
    db.commit()
    db.refresh(incident)
    log_action(db, current_user.id, "CREATE", "SafetyIncident", incident.id)
    return incident


@router.put("/{incident_id}", response_model=SafetyIncidentOut)
def update_incident(
    incident_id: int,
    payload: SafetyIncidentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = db.query(SafetyIncident).filter(SafetyIncident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(incident, key, value)
    db.commit()
    db.refresh(incident)
    log_action(db, current_user.id, "UPDATE", "SafetyIncident", incident.id)
    return incident


@router.delete("/{incident_id}", status_code=204)
def delete_incident(
    incident_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    incident = db.query(SafetyIncident).filter(SafetyIncident.id == incident_id).first()
    if not incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    log_action(db, current_user.id, "DELETE", "SafetyIncident", incident.id)
    db.delete(incident)
    db.commit()
