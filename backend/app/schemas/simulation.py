from datetime import datetime
from typing import Any, Dict, List, Optional

from pydantic import BaseModel


# --- Session ---
class SimulationSessionCreate(BaseModel):
    project_id: int
    name: str = "Untitled Simulation"


class SimulationSessionOut(BaseModel):
    id: int
    project_id: int
    created_by: int
    name: str
    status: str
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


# --- Scenario inputs ---
class ScheduleSimInput(BaseModel):
    milestone_id: Optional[int] = None
    phase: Optional[str] = None
    delay_days: int


class CostSimInput(BaseModel):
    time_impact_days: int
    daily_overhead_cost: float
    escalation_pct: float = 0


class CashflowSimInput(BaseModel):
    milestone_delay_days: int


class LDSimInput(BaseModel):
    delay_days: int
    daily_ld_rate: Optional[float] = None  # None = use project rate


class ResourceSimInput(BaseModel):
    activity_id: int
    additional_resources: int
    productivity_gain_pct: float = 15  # default 15% faster per resource


# --- Run request ---
class SimulationRunRequest(BaseModel):
    session_id: int
    type: str  # Schedule / Cost / Cashflow / LD / Resource
    input_parameters: Dict[str, Any]


# --- Scenario output ---
class SimulationScenarioOut(BaseModel):
    id: int
    simulation_session_id: int
    type: str
    input_parameters: Dict[str, Any]
    output_results: Dict[str, Any]
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}


# --- Full session with scenarios ---
class SimulationSessionDetail(BaseModel):
    id: int
    project_id: int
    created_by: int
    name: str
    status: str
    created_at: Optional[datetime] = None
    scenarios: List[SimulationScenarioOut] = []

    model_config = {"from_attributes": True}
