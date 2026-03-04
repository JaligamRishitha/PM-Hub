from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class MilestonePaymentCreate(BaseModel):
    milestone_id: int
    payment_percentage: float
    payment_value: float
    invoice_number: Optional[str] = None
    invoice_date: Optional[date] = None
    payment_status: str = "Pending"


class MilestonePaymentUpdate(BaseModel):
    payment_percentage: Optional[float] = None
    payment_value: Optional[float] = None
    invoice_number: Optional[str] = None
    invoice_date: Optional[date] = None
    payment_status: Optional[str] = None


class MilestonePaymentOut(BaseModel):
    id: int
    milestone_id: int
    payment_percentage: float
    payment_value: float
    invoice_number: Optional[str] = None
    invoice_date: Optional[date] = None
    payment_status: str
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
