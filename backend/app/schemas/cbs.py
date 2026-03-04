from datetime import datetime
from typing import Optional

from pydantic import BaseModel


class CBSCreate(BaseModel):
    project_id: int
    wbs_code: str
    description: str
    budget_cost: float = 0
    actual_cost: float = 0
    forecast_cost: float = 0
    approved_variation: float = 0


class CBSUpdate(BaseModel):
    wbs_code: Optional[str] = None
    description: Optional[str] = None
    budget_cost: Optional[float] = None
    actual_cost: Optional[float] = None
    forecast_cost: Optional[float] = None
    approved_variation: Optional[float] = None


class CBSOut(BaseModel):
    id: int
    project_id: int
    wbs_code: str
    description: str
    budget_cost: float
    actual_cost: float
    forecast_cost: float = 0
    approved_variation: float
    variance: float
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
