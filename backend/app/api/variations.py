from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import ApprovedVariation
from app.schemas.variation import VariationCreate, VariationUpdate, VariationOut

router = APIRouter(prefix="/api/variations", tags=["Variations"])


@router.get("", response_model=List[VariationOut])
def list_variations(
    project_id: int = None,
    approval_status: str = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    q = db.query(ApprovedVariation)
    if project_id:
        q = q.filter(ApprovedVariation.project_id == project_id)
    if approval_status:
        q = q.filter(ApprovedVariation.approval_status == approval_status)
    return q.order_by(ApprovedVariation.id.desc()).all()


@router.post("", response_model=VariationOut, status_code=201)
def create_variation(data: VariationCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    var = ApprovedVariation(**data.model_dump())
    db.add(var)
    db.commit()
    db.refresh(var)
    return var


@router.get("/{var_id}", response_model=VariationOut)
def get_variation(var_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    var = db.query(ApprovedVariation).filter(ApprovedVariation.id == var_id).first()
    if not var:
        raise HTTPException(404, "Variation not found")
    return var


@router.put("/{var_id}", response_model=VariationOut)
def update_variation(var_id: int, data: VariationUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    var = db.query(ApprovedVariation).filter(ApprovedVariation.id == var_id).first()
    if not var:
        raise HTTPException(404, "Variation not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(var, k, v)
    db.commit()
    db.refresh(var)
    return var


@router.delete("/{var_id}", status_code=204)
def delete_variation(var_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    var = db.query(ApprovedVariation).filter(ApprovedVariation.id == var_id).first()
    if not var:
        raise HTTPException(404, "Variation not found")
    db.delete(var)
    db.commit()
