from datetime import date, datetime
from typing import Optional

from pydantic import BaseModel


class HSEChecklistCreate(BaseModel):
    project_id: int
    checklist_item: str
    status: str = "Pending"
    last_inspection_date: Optional[date] = None


class HSEChecklistUpdate(BaseModel):
    checklist_item: Optional[str] = None
    status: Optional[str] = None
    last_inspection_date: Optional[date] = None


class HSEChecklistOut(BaseModel):
    id: int
    project_id: int
    checklist_item: str
    status: str
    last_inspection_date: Optional[date] = None
    created_at: Optional[datetime] = None

    model_config = {"from_attributes": True}
