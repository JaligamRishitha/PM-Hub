from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class ActivityCreate(BaseModel):
    project_id: int
    wbs_id: Optional[int] = None
    activity_code: Optional[str] = None
    activity_name: str
    phase: str
    planned_start: date
    planned_finish: date
    actual_start: Optional[date] = None
    actual_finish: Optional[date] = None
    completion_pct: float = 0
    is_milestone: bool = False
    is_critical: bool = False


class ActivityUpdate(BaseModel):
    wbs_id: Optional[int] = None
    activity_code: Optional[str] = None
    activity_name: Optional[str] = None
    phase: Optional[str] = None
    planned_start: Optional[date] = None
    planned_finish: Optional[date] = None
    actual_start: Optional[date] = None
    actual_finish: Optional[date] = None
    completion_pct: Optional[float] = None
    is_milestone: Optional[bool] = None
    is_critical: Optional[bool] = None


class ActivityOut(BaseModel):
    id: int
    project_id: int
    wbs_id: Optional[int] = None
    activity_code: Optional[str] = None
    activity_name: str
    phase: str
    planned_start: date
    planned_finish: date
    actual_start: Optional[date] = None
    actual_finish: Optional[date] = None
    completion_pct: float
    is_milestone: bool = False
    is_critical: bool = False
    status: str
    delay_days: int
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
