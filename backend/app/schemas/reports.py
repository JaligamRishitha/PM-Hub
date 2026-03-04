from typing import List, Optional

from pydantic import BaseModel


# ---------- Shared ----------

class EVMetrics(BaseModel):
    bac: float = 0
    pv: float = 0
    ev: float = 0
    ac: float = 0
    cv: float = 0
    sv: float = 0
    cpi: float = 1.0
    spi: float = 1.0
    eac: float = 0
    vac: float = 0
    overall_completion: float = 0


class SCurvePoint(BaseModel):
    month: str
    PV: float = 0
    EV: float = 0
    AC: Optional[float] = None


# ---------- 1. Overall Project Report ----------

class ScheduleSummary(BaseModel):
    total_activities: int = 0
    completed_activities: int = 0
    remaining_activities: int = 0
    critical_activities: int = 0
    schedule_variance_days: int = 0
    spi: float = 1.0


class FinancialSummary(BaseModel):
    contract_value: float = 0
    budget_bac: float = 0
    actual_cost: float = 0
    approved_variations: float = 0
    pending_variations: float = 0
    ld_exposure: float = 0
    forecast_margin_pct: float = 0


class MilestoneSummaryItem(BaseModel):
    name: str
    planned_date: str
    delay_days: int = 0


class MilestoneSummary(BaseModel):
    total: int = 0
    completed: int = 0
    delayed: int = 0
    upcoming_30_days: int = 0
    top_milestones: List[MilestoneSummaryItem] = []


class OverallProjectReportResponse(BaseModel):
    project_name: str
    client: str = ""
    contract_value: float = 0
    start_date: str = ""
    planned_finish: str = ""
    forecast_finish: str = ""
    data_date: str = ""
    schedule_health_pct: int = 100
    cost_health_pct: int = 100
    risk_score: float = 0
    ld_exposure: float = 0
    ev_metrics: EVMetrics
    s_curve_data: List[SCurvePoint] = []
    schedule_summary: ScheduleSummary
    financial_summary: FinancialSummary
    milestone_summary: MilestoneSummary


# ---------- 2. Key Milestone Report ----------

class MilestoneReportItem(BaseModel):
    id: int
    name: str
    phase: str = ""
    planned_date: str
    actual_date: Optional[str] = None
    status: str
    is_critical: bool = False
    delay_days: int = 0


class MilestoneStatusDistribution(BaseModel):
    status: str
    count: int


class MilestoneReportSummary(BaseModel):
    total: int = 0
    completed: int = 0
    delayed: int = 0
    critical: int = 0
    avg_delay_days: float = 0


class KeyMilestoneReportResponse(BaseModel):
    project_start_date: str = ""
    summary: MilestoneReportSummary
    status_distribution: List[MilestoneStatusDistribution] = []
    milestones: List[MilestoneReportItem] = []


# ---------- 3. Earned Value Report ----------

class VarianceTrendPoint(BaseModel):
    month: str
    CV: float = 0
    SV: float = 0


class EarnedValueReportResponse(BaseModel):
    ev_metrics: EVMetrics
    s_curve_data: List[SCurvePoint] = []
    variance_trend: List[VarianceTrendPoint] = []


# ---------- 4. Issues / Risk Report ----------

class RiskItem(BaseModel):
    id: int
    risk_code: str
    title: str
    category: Optional[str] = None
    probability: int
    impact: int
    risk_score: int
    owner: Optional[str] = None
    status: str
    cost_exposure: float = 0
    mitigation_plan: Optional[str] = None


class RiskHeatmapCell(BaseModel):
    probability: int
    impact: int
    count: int


class RiskCategoryCount(BaseModel):
    category: str
    count: int


class RiskSummary(BaseModel):
    total_open: int = 0
    total_closed: int = 0
    avg_risk_score: float = 0
    total_cost_exposure: float = 0
    top_risks: List[RiskItem] = []
    heatmap: List[RiskHeatmapCell] = []
    categories: List[RiskCategoryCount] = []


class IssueItem(BaseModel):
    id: int
    issue_code: str
    title: str
    priority: str = "Medium"
    status: str = "Open"
    assigned_to: Optional[str] = None
    raised_date: Optional[str] = None
    due_date: Optional[str] = None
    is_overdue: bool = False


class IssueStatusCount(BaseModel):
    status: str
    count: int


class IssuePriorityCount(BaseModel):
    priority: str
    count: int


class IssueSummary(BaseModel):
    total: int = 0
    open_count: int = 0
    in_progress: int = 0
    resolved: int = 0
    overdue: int = 0
    status_breakdown: List[IssueStatusCount] = []
    priority_breakdown: List[IssuePriorityCount] = []


class IssuesRiskReportResponse(BaseModel):
    risk_summary: RiskSummary
    risks: List[RiskItem] = []
    issues: List[IssueItem] = []
    issue_summary: IssueSummary
