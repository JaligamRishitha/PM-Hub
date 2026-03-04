from typing import List, Optional

from pydantic import BaseModel


class DashboardSummary(BaseModel):
    total_projects: int
    active_projects: int
    delayed_projects: int
    total_milestones: int
    delayed_milestones: int
    total_budget: float
    total_actual_cost: float
    total_contract_value: float
    total_forecast_cost: float
    active_compensation_events: int
    open_safety_incidents: int
    open_risks: int
    overdue_issues: int
    schedule_health_pct: float
    cost_health_pct: float
    ev_performance: float = 1.0
    risk_exposure_score: float
    ld_exposure: float
    margin_pct: float
    safety_score: float = 100.0
    projects_gate_b: int = 0
    projects_gate_c: int = 0
    design_completion: int = 0
    construction: int = 0
    commissioned: int = 0


class UpcomingMilestone(BaseModel):
    id: int
    project_name: str
    milestone_name: str
    planned_date: str
    is_critical: bool


class CashflowItem(BaseModel):
    month: str
    expected: float
    received: float


class BudgetVsActual(BaseModel):
    project_name: str
    budget: float
    actual: float
    forecast: float
    variance: float


class PortfolioHealth(BaseModel):
    project_id: int
    project_name: str
    schedule_health: str  # Green / Amber / Red
    cost_health: str
    risk_level: str
    overall_status: str
    spi: float
    cpi: float
    ld_exposure: float


class PlannedVsActualItem(BaseModel):
    month: str
    planned: float
    actual: float
    projects: List[str]  # project names active in this month


class RiskHeatmapCell(BaseModel):
    probability: int
    impact: int
    count: int
    risk_ids: List[int]


class DelayedMilestoneItem(BaseModel):
    id: int
    project_name: str
    milestone_name: str
    planned_date: str
    actual_date: str
    delay_days: int
    is_critical: bool


class OpenRiskItem(BaseModel):
    id: int
    project_name: str
    risk_code: str
    title: str
    category: Optional[str] = None
    probability: int
    impact: int
    risk_score: int
    owner: Optional[str] = None
    status: str
