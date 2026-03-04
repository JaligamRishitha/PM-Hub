from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CompensationEventCreate(BaseModel):
    project_id: int
    event_name: str
    linked_wbs: Optional[str] = None
    time_impact_days: int = 0
    daily_overhead_cost: float = 0
    status: str = "Pending"


class CompensationEventUpdate(BaseModel):
    event_name: Optional[str] = None
    linked_wbs: Optional[str] = None
    time_impact_days: Optional[int] = None
    daily_overhead_cost: Optional[float] = None
    status: Optional[str] = None


class CompensationEventOut(BaseModel):
    id: int
    project_id: int
    event_name: str
    linked_wbs: Optional[str] = None
    time_impact_days: int
    daily_overhead_cost: float
    cost_impact: float
    status: str
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
