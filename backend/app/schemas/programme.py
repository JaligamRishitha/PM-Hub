from pydantic import BaseModel
from typing import Optional
from datetime import date, datetime


class ProgrammeCreate(BaseModel):
    organization_id: int
    name: str
    code: str
    description: Optional[str] = None
    status: Optional[str] = "Active"
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ProgrammeUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    description: Optional[str] = None
    status: Optional[str] = None
    start_date: Optional[date] = None
    end_date: Optional[date] = None


class ProgrammeOut(BaseModel):
    id: int
    organization_id: int
    name: str
    code: str
    description: Optional[str] = None
    status: str
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
