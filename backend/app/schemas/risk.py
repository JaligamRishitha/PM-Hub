from pydantic import BaseModel, Field
from typing import Optional
from datetime import date, datetime


class RiskCreate(BaseModel):
    project_id: int
    risk_code: str
    title: str
    description: Optional[str] = None
    category: Optional[str] = None
    probability: int = Field(ge=1, le=5)
    impact: int = Field(ge=1, le=5)
    mitigation_plan: Optional[str] = None
    contingency_plan: Optional[str] = None
    owner: Optional[str] = None
    status: Optional[str] = "Open"
    identified_date: Optional[date] = None
    review_date: Optional[date] = None
    cost_exposure: Optional[float] = 0


class RiskUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    category: Optional[str] = None
    probability: Optional[int] = Field(None, ge=1, le=5)
    impact: Optional[int] = Field(None, ge=1, le=5)
    mitigation_plan: Optional[str] = None
    contingency_plan: Optional[str] = None
    owner: Optional[str] = None
    status: Optional[str] = None
    review_date: Optional[date] = None
    cost_exposure: Optional[float] = None


class RiskOut(BaseModel):
    id: int
    project_id: int
    risk_code: str
    title: str
    description: Optional[str] = None
    category: Optional[str] = None
    probability: int
    impact: int
    risk_score: int
    mitigation_plan: Optional[str] = None
    contingency_plan: Optional[str] = None
    owner: Optional[str] = None
    status: str
    identified_date: Optional[date] = None
    review_date: Optional[date] = None
    cost_exposure: Optional[float] = 0
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
