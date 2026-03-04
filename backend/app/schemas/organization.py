from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class OrganizationCreate(BaseModel):
    name: str
    code: str
    description: Optional[str] = None


class OrganizationUpdate(BaseModel):
    name: Optional[str] = None
    code: Optional[str] = None
    description: Optional[str] = None
    is_active: Optional[bool] = None


class OrganizationOut(BaseModel):
    id: int
    name: str
    code: str
    description: Optional[str] = None
    is_active: bool
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
