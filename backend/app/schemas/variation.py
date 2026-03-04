from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


class VariationCreate(BaseModel):
    project_id: int
    variation_code: str
    description: str
    value: float = 0
    cost_impact: Optional[float] = 0
    schedule_impact_days: Optional[int] = 0
    approval_status: Optional[str] = "Pending"
    submitted_date: Optional[date] = None
    approval_date: Optional[date] = None
    approved_by: Optional[str] = None


class VariationUpdate(BaseModel):
    description: Optional[str] = None
    value: Optional[float] = None
    cost_impact: Optional[float] = None
    schedule_impact_days: Optional[int] = None
    approval_status: Optional[str] = None
    approval_date: Optional[date] = None
    approved_by: Optional[str] = None


class VariationOut(BaseModel):
    id: int
    project_id: int
    variation_code: str
    description: str
    value: float
    cost_impact: Optional[float] = 0
    schedule_impact_days: Optional[int] = 0
    approval_status: str
    submitted_date: Optional[date] = None
    approval_date: Optional[date] = None
    approved_by: Optional[str] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
