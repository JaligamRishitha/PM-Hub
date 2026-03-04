from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class SafetyIncidentCreate(BaseModel):
    project_id: int
    incident_type: str
    severity: str
    reported_date: date
    resolved_date: Optional[date] = None
    status: str = "Open"
    penalty_cost: float = 0
    description: Optional[str] = None
    lost_time_hours: float = 0
    location: Optional[str] = None
    reported_by: Optional[str] = None


class SafetyIncidentUpdate(BaseModel):
    incident_type: Optional[str] = None
    severity: Optional[str] = None
    reported_date: Optional[date] = None
    resolved_date: Optional[date] = None
    status: Optional[str] = None
    penalty_cost: Optional[float] = None
    description: Optional[str] = None
    lost_time_hours: Optional[float] = None
    location: Optional[str] = None
    reported_by: Optional[str] = None


class SafetyIncidentOut(BaseModel):
    id: int
    project_id: int
    incident_type: str
    severity: str
    reported_date: date
    resolved_date: Optional[date] = None
    status: str
    penalty_cost: float
    description: Optional[str] = None
    lost_time_hours: float = 0
    location: Optional[str] = None
    reported_by: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
