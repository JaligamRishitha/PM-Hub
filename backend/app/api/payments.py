from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models.milestone_payment import MilestonePayment
from app.models.user import User
from app.schemas.milestone_payment import (
    MilestonePaymentCreate,
    MilestonePaymentOut,
    MilestonePaymentUpdate,
)
from app.services.audit import log_action

router = APIRouter(prefix="/api/payments", tags=["payments"])


@router.get("/", response_model=List[MilestonePaymentOut])
def list_payments(
    milestone_id: int = None,
    skip: int = 0,
    limit: int = 100,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    query = db.query(MilestonePayment)
    if milestone_id:
        query = query.filter(MilestonePayment.milestone_id == milestone_id)
    return query.offset(skip).limit(limit).all()


@router.get("/{payment_id}", response_model=MilestonePaymentOut)
def get_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payment = db.query(MilestonePayment).filter(MilestonePayment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    return payment


@router.post("/", response_model=MilestonePaymentOut, status_code=201)
def create_payment(
    payload: MilestonePaymentCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payment = MilestonePayment(**payload.model_dump())
    db.add(payment)
    db.commit()
    db.refresh(payment)
    log_action(db, current_user.id, "CREATE", "Payment", payment.id)
    return payment


@router.put("/{payment_id}", response_model=MilestonePaymentOut)
def update_payment(
    payment_id: int,
    payload: MilestonePaymentUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payment = db.query(MilestonePayment).filter(MilestonePayment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    for key, value in payload.model_dump(exclude_unset=True).items():
        setattr(payment, key, value)
    db.commit()
    db.refresh(payment)
    log_action(db, current_user.id, "UPDATE", "Payment", payment.id)
    return payment


@router.delete("/{payment_id}", status_code=204)
def delete_payment(
    payment_id: int,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    payment = db.query(MilestonePayment).filter(MilestonePayment.id == payment_id).first()
    if not payment:
        raise HTTPException(status_code=404, detail="Payment not found")
    log_action(db, current_user.id, "DELETE", "Payment", payment.id)
    db.delete(payment)
    db.commit()
