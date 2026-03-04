from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.cbs import CBS
from app.models.user import User
from app.schemas.cbs import CBSCreate, CBSOut, CBSUpdate
from app.services.audit import log_action

router = APIRouter(prefix="/api/cbs", tags=["cbs"])


@router.get("/", response_model=List[CBSOut])
def list_cbs(
    project_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(CBS)
    if project_id:
        query = query.filter(CBS.project_id == project_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{cbs_id}", response_model=CBSOut)
def get_cbs(
    cbs_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cbs = db.query(CBS).filter(CBS.id == cbs_id).first()
    if not cbs:
        raise HTTPException(status_code=404, detail="CBS item not found")
    return cbs


@router.post("/", response_model=CBSOut, status_code=201)
def create_cbs(
    payload: CBSCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cbs = CBS(**payload.model_dump())
    db.add(cbs)
    db.commit()
    db.refresh(cbs)
    log_action(db, current_user.id, "CREATE", "CBS", cbs.id, cbs.wbs_code)
    return cbs


@router.put("/{cbs_id}", response_model=CBSOut)
def update_cbs(
    cbs_id: int,
    payload: CBSUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cbs = db.query(CBS).filter(CBS.id == cbs_id).first()
    if not cbs:
        raise HTTPException(status_code=404, detail="CBS item not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(cbs, key, value)
    db.commit()
    db.refresh(cbs)
    log_action(db, current_user.id, "UPDATE", "CBS", cbs.id, cbs.wbs_code)
    return cbs


@router.delete("/{cbs_id}", status_code=204)
def delete_cbs(
    cbs_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    cbs = db.query(CBS).filter(CBS.id == cbs_id).first()
    if not cbs:
        raise HTTPException(status_code=404, detail="CBS item not found")
    log_action(db, current_user.id, "DELETE", "CBS", cbs.id, cbs.wbs_code)
    db.delete(cbs)
    db.commit()
