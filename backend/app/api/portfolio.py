from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import Organization, Programme, Project
from app.schemas.organization import OrganizationCreate, OrganizationUpdate, OrganizationOut
from app.schemas.programme import ProgrammeCreate, ProgrammeUpdate, ProgrammeOut

router = APIRouter(prefix="/api/portfolio", tags=["Portfolio"])


# ── Organizations ──────────────────────────────────────────

@router.get("/organizations", response_model=List[OrganizationOut])
def list_organizations(db: Session = Depends(get_db), _=Depends(get_current_user)):
    return db.query(Organization).order_by(Organization.name).all()


@router.post("/organizations", response_model=OrganizationOut, status_code=201)
def create_organization(data: OrganizationCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    org = Organization(**data.model_dump())
    db.add(org)
    db.commit()
    db.refresh(org)
    return org


@router.put("/organizations/{org_id}", response_model=OrganizationOut)
def update_organization(org_id: int, data: OrganizationUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(404, "Organization not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(org, k, v)
    db.commit()
    db.refresh(org)
    return org


@router.delete("/organizations/{org_id}", status_code=204)
def delete_organization(org_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    org = db.query(Organization).filter(Organization.id == org_id).first()
    if not org:
        raise HTTPException(404, "Organization not found")
    db.delete(org)
    db.commit()


# ── Programmes ─────────────────────────────────────────────

@router.get("/programmes", response_model=List[ProgrammeOut])
def list_programmes(organization_id: int = None, db: Session = Depends(get_db), _=Depends(get_current_user)):
    q = db.query(Programme)
    if organization_id:
        q = q.filter(Programme.organization_id == organization_id)
    return q.order_by(Programme.name).all()


@router.post("/programmes", response_model=ProgrammeOut, status_code=201)
def create_programme(data: ProgrammeCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    prog = Programme(**data.model_dump())
    db.add(prog)
    db.commit()
    db.refresh(prog)
    return prog


@router.put("/programmes/{prog_id}", response_model=ProgrammeOut)
def update_programme(prog_id: int, data: ProgrammeUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    prog = db.query(Programme).filter(Programme.id == prog_id).first()
    if not prog:
        raise HTTPException(404, "Programme not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(prog, k, v)
    db.commit()
    db.refresh(prog)
    return prog


@router.delete("/programmes/{prog_id}", status_code=204)
def delete_programme(prog_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    prog = db.query(Programme).filter(Programme.id == prog_id).first()
    if not prog:
        raise HTTPException(404, "Programme not found")
    db.delete(prog)
    db.commit()


# ── Portfolio KPIs ─────────────────────────────────────────

@router.get("/hierarchy")
def get_portfolio_hierarchy(db: Session = Depends(get_db), _=Depends(get_current_user)):
    """Returns the full Organization → Programme → Project tree."""
    orgs = db.query(Organization).filter(Organization.is_active == True).all()
    result = []
    for org in orgs:
        programmes = db.query(Programme).filter(Programme.organization_id == org.id).all()
        prog_list = []
        for prog in programmes:
            projects = db.query(Project).filter(Project.programme_id == prog.id).all()
            prog_list.append({
                "id": prog.id,
                "name": prog.name,
                "code": prog.code,
                "status": prog.status,
                "projects": [
                    {
                        "id": p.id,
                        "name": p.name,
                        "code": p.code,
                        "status": p.status,
                        "client": p.client,
                        "total_budget": float(p.total_budget or 0),
                        "contract_value": float(p.contract_value or 0),
                    }
                    for p in projects
                ],
            })
        result.append({
            "id": org.id,
            "name": org.name,
            "code": org.code,
            "programmes": prog_list,
        })
    return result


@router.get("/kpis")
def get_portfolio_kpis(db: Session = Depends(get_db), _=Depends(get_current_user)):
    """Aggregated portfolio-level KPIs across all projects."""
    from app.models import Risk, Issue, SafetyIncident, CBS
    from sqlalchemy import func as sqf

    projects = db.query(Project).all()
    total_budget = sum(float(p.total_budget or 0) for p in projects)
    total_contract = sum(float(p.contract_value or 0) for p in projects)
    total_forecast = sum(float(p.forecast_cost or 0) for p in projects)

    # Actual cost from CBS
    actual_row = db.query(sqf.sum(CBS.actual_cost)).scalar()
    total_actual = float(actual_row or 0)

    at_risk = sum(1 for p in projects if p.status == "At Risk")
    active = sum(1 for p in projects if p.status == "Active")
    completed = sum(1 for p in projects if p.status == "Completed")

    open_risks = db.query(Risk).filter(Risk.status == "Open").count()
    high_risks = db.query(Risk).filter(Risk.status == "Open", Risk.probability >= 4).count()
    open_issues = db.query(Issue).filter(Issue.status.in_(["Open", "In Progress"])).count()
    open_incidents = db.query(SafetyIncident).filter(SafetyIncident.status == "Open").count()

    return {
        "total_projects": len(projects),
        "active_projects": active,
        "completed_projects": completed,
        "at_risk_projects": at_risk,
        "total_budget": total_budget,
        "total_contract_value": total_contract,
        "total_forecast_cost": total_forecast,
        "total_actual_cost": total_actual,
        "budget_variance": total_budget - total_actual,
        "open_risks": open_risks,
        "high_risks": high_risks,
        "open_issues": open_issues,
        "open_incidents": open_incidents,
    }
