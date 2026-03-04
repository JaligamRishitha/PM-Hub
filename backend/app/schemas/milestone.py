from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class MilestoneCreate(BaseModel):
    project_id: int
    name: str
    phase: str
    planned_date: date
    actual_date: Optional[date] = None
    is_critical: bool = False


class MilestoneUpdate(BaseModel):
    name: Optional[str] = None
    phase: Optional[str] = None
    planned_date: Optional[date] = None
    actual_date: Optional[date] = None
    is_critical: Optional[bool] = None


class MilestoneOut(BaseModel):
    id: int
    project_id: int
    name: str
    phase: str
    planned_date: date
    actual_date: Optional[date] = None
    is_critical: bool
    status: str
    delay_days: int
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
