from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime


class WBSCreate(BaseModel):
    project_id: int
    parent_id: Optional[int] = None
    code: str
    name: str
    level: Optional[int] = 1
    sort_order: Optional[int] = 0


class WBSUpdate(BaseModel):
    parent_id: Optional[int] = None
    code: Optional[str] = None
    name: Optional[str] = None
    level: Optional[int] = None
    sort_order: Optional[int] = None


class WBSOut(BaseModel):
    id: int
    project_id: int
    parent_id: Optional[int] = None
    code: str
    name: str
    level: int
    sort_order: int
    children: Optional[List["WBSOut"]] = []
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True


WBSOut.model_rebuild()
