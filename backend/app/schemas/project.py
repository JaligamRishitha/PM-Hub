from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class ProjectCreate(BaseModel):
    programme_id: Optional[int] = None
    name: str
    code: Optional[str] = None
    client: str
    description: Optional[str] = None
    start_date: date
    end_date: date
    contract_completion_date: Optional[date] = None
    status: str = "Active"
    phase: Optional[str] = "Gate B"
    total_budget: float = 0
    contract_value: float = 0
    forecast_cost: float = 0
    daily_ld_rate: float = 0
    ld_cap_pct: float = 10.0
    location: Optional[str] = None
    project_manager: Optional[str] = None


class ProjectUpdate(BaseModel):
    programme_id: Optional[int] = None
    name: Optional[str] = None
    code: Optional[str] = None
    client: Optional[str] = None
    description: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    contract_completion_date: Optional[date] = None
    actual_completion_date: Optional[date] = None
    status: Optional[str] = None
    phase: Optional[str] = None
    total_budget: Optional[float] = None
    contract_value: Optional[float] = None
    forecast_cost: Optional[float] = None
    daily_ld_rate: Optional[float] = None
    ld_cap_pct: Optional[float] = None
    location: Optional[str] = None
    project_manager: Optional[str] = None


class ProjectOut(BaseModel):
    id: int
    programme_id: Optional[int] = None
    name: str
    code: Optional[str] = None
    client: str
    description: Optional[str] = None
    start_date: date
    end_date: date
    contract_completion_date: Optional[date] = None
    actual_completion_date: Optional[date] = None
    status: str
    phase: Optional[str] = None
    total_budget: float
    contract_value: float = 0
    forecast_cost: float = 0
    daily_ld_rate: float
    ld_cap_pct: float = 10.0
    location: Optional[str] = None
    project_manager: Optional[str] = None
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
