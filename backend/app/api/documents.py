from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import Document
from app.schemas.document import DocumentCreate, DocumentUpdate, DocumentOut

router = APIRouter(prefix="/api/documents", tags=["Documents"])


@router.get("", response_model=List[DocumentOut])
def list_documents(
    project_id: int = None,
    category: str = None,
    status: str = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    q = db.query(Document)
    if project_id:
        q = q.filter(Document.project_id == project_id)
    if category:
        q = q.filter(Document.category == category)
    if status:
        q = q.filter(Document.status == status)
    return q.order_by(Document.id.desc()).all()


@router.post("", response_model=DocumentOut, status_code=201)
def create_document(data: DocumentCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    doc = Document(**data.model_dump())
    db.add(doc)
    db.commit()
    db.refresh(doc)
    return doc


@router.get("/{doc_id}", response_model=DocumentOut)
def get_document(doc_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    doc = db.query(Document).filter(Document.id == doc_id).first()
    if not doc:
        raise HTTPException(404, "Document not found")
    return doc


@router.put("/{doc_id}", response_model=DocumentOut)
def update_document(doc_id: int, data: DocumentUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    doc = db.query(Document).filter(Document.id == doc_id).first()
    if not doc:
        raise HTTPException(404, "Document not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(doc, k, v)
    db.commit()
    db.refresh(doc)
    return doc


@router.delete("/{doc_id}", status_code=204)
def delete_document(doc_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    doc = db.query(Document).filter(Document.id == doc_id).first()
    if not doc:
        raise HTTPException(404, "Document not found")
    db.delete(doc)
    db.commit()
