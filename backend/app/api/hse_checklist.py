from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.hse_checklist import HSEChecklist
from app.models.user import User
from app.schemas.hse_checklist import HSEChecklistCreate, HSEChecklistOut, HSEChecklistUpdate
from app.services.audit import log_action

router = APIRouter(prefix="/api/hse-checklist", tags=["hse_checklist"])


@router.get("/", response_model=List[HSEChecklistOut])
def list_checklist(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(HSEChecklist)
    if project_id:
        query = query.filter(HSEChecklist.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{item_id}", response_model=HSEChecklistOut)
def get_item(
    item_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = db.query(HSEChecklist).filter(HSEChecklist.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Checklist item not found")
    return item


@router.post("/", response_model=HSEChecklistOut, status_code=201)
def create_item(
    payload: HSEChecklistCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = HSEChecklist(**payload.model_dump())
    db.add(item)
    db.commit()
    db.refresh(item)
    log_action(db, current_user.id, "CREATE", "HSEChecklist", item.id)
    return item


@router.put("/{item_id}", response_model=HSEChecklistOut)
def update_item(
    item_id: int,
    payload: HSEChecklistUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = db.query(HSEChecklist).filter(HSEChecklist.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Checklist item not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(item, key, value)
    db.commit()
    db.refresh(item)
    log_action(db, current_user.id, "UPDATE", "HSEChecklist", item.id)
    return item


@router.delete("/{item_id}", status_code=204)
def delete_item(
    item_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    item = db.query(HSEChecklist).filter(HSEChecklist.id == item_id).first()
    if not item:
        raise HTTPException(status_code=404, detail="Checklist item not found")
    log_action(db, current_user.id, "DELETE", "HSEChecklist", item.id)
    db.delete(item)
    db.commit()
