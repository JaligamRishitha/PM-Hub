from pydantic import BaseModel
from typing import Optional
from datetime import datetime


class DocumentCreate(BaseModel):
    project_id: int
    doc_code: str
    title: str
    category: str
    revision: Optional[str] = "A"
    status: Optional[str] = "Draft"
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    uploaded_by: Optional[str] = None
    description: Optional[str] = None


class DocumentUpdate(BaseModel):
    title: Optional[str] = None
    category: Optional[str] = None
    revision: Optional[str] = None
    status: Optional[str] = None
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    description: Optional[str] = None


class DocumentOut(BaseModel):
    id: int
    project_id: int
    doc_code: str
    title: str
    category: str
    revision: str
    status: str
    file_path: Optional[str] = None
    file_size: Optional[int] = None
    uploaded_by: Optional[str] = None
    upload_date: Optional[datetime] = None
    description: Optional[str] = None
    created_at: Optional[datetime] = None

    class Config:
        from_attributes = True
