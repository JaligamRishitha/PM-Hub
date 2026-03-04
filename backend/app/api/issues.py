from typing import List
from datetime import date

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import Issue
from app.schemas.issue import IssueCreate, IssueUpdate, IssueOut

router = APIRouter(prefix="/api/issues", tags=["Issues"])


@router.get("", response_model=List[IssueOut])
def list_issues(
    project_id: int = None,
    status: str = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    q = db.query(Issue)
    if project_id:
        q = q.filter(Issue.project_id == project_id)
    if status:
        q = q.filter(Issue.status == status)
    return q.order_by(Issue.id.desc()).all()


@router.get("/overdue", response_model=List[IssueOut])
def overdue_issues(
    project_id: int = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    """Returns issues past due date that are still open."""
    q = db.query(Issue).filter(
        Issue.status.in_(["Open", "In Progress"]),
        Issue.due_date < date.today(),
    )
    if project_id:
        q = q.filter(Issue.project_id == project_id)
    return q.order_by(Issue.due_date).all()


@router.post("", response_model=IssueOut, status_code=201)
def create_issue(data: IssueCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    issue = Issue(**data.model_dump())
    db.add(issue)
    db.commit()
    db.refresh(issue)
    return issue


@router.get("/{issue_id}", response_model=IssueOut)
def get_issue(issue_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()
    if not issue:
        raise HTTPException(404, "Issue not found")
    return issue


@router.put("/{issue_id}", response_model=IssueOut)
def update_issue(issue_id: int, data: IssueUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()
    if not issue:
        raise HTTPException(404, "Issue not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(issue, k, v)
    db.commit()
    db.refresh(issue)
    return issue


@router.delete("/{issue_id}", status_code=204)
def delete_issue(issue_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    issue = db.query(Issue).filter(Issue.id == issue_id).first()
    if not issue:
        raise HTTPException(404, "Issue not found")
    db.delete(issue)
    db.commit()
