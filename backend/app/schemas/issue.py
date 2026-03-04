from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


class IssueCreate(BaseModel):
    project_id: int
    issue_code: str
    title: str
    description: Optional[str] = None
    priority: Optional[str] = "Medium"
    assigned_to: Optional[str] = None
    raised_by: Optional[str] = None
    raised_date: Optional[date] = None
    due_date: Optional[date] = None
    status: Optional[str] = "Open"


class IssueUpdate(BaseModel):
    title: Optional[str] = None
    description: Optional[str] = None
    priority: Optional[str] = None
    assigned_to: Optional[str] = None
    due_date: Optional[date] = None
    resolution_date: Optional[date] = None
    resolution_notes: Optional[str] = None
    status: Optional[str] = None


class IssueOut(BaseModel):
    id: int
    project_id: int
    issue_code: str
    title: str
    description: Optional[str] = None
    priority: str
    assigned_to: Optional[str] = None
    raised_by: Optional[str] = None
    raised_date: Optional[date] = None
    due_date: Optional[date] = None
    resolution_date: Optional[date] = None
    resolution_notes: Optional[str] = None
    status: str
    is_overdue: bool = False
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
