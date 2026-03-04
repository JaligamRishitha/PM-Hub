from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import Risk
from app.schemas.risk import RiskCreate, RiskUpdate, RiskOut
from app.schemas.dashboard import RiskHeatmapCell

router = APIRouter(prefix="/api/risks", tags=["Risks"])


@router.get("", response_model=List[RiskOut])
def list_risks(
    project_id: int = None,
    status: str = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    q = db.query(Risk)
    if project_id:
        q = q.filter(Risk.project_id == project_id)
    if status:
        q = q.filter(Risk.status == status)
    return q.order_by(Risk.id.desc()).all()


@router.get("/heatmap", response_model=List[RiskHeatmapCell])
def risk_heatmap(
    project_id: int = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    """Returns risk counts grouped by probability × impact for the heatmap."""
    q = db.query(Risk).filter(Risk.status == "Open")
    if project_id:
        q = q.filter(Risk.project_id == project_id)

    risks = q.all()
    grid = {}
    for r in risks:
        key = (r.probability, r.impact)
        if key not in grid:
            grid[key] = {"probability": r.probability, "impact": r.impact, "count": 0, "risk_ids": []}
        grid[key]["count"] += 1
        grid[key]["risk_ids"].append(r.id)

    return list(grid.values())


@router.get("/top", response_model=List[RiskOut])
def top_risks(
    limit: int = 5,
    project_id: int = None,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    """Returns top N risks by risk score."""
    q = db.query(Risk).filter(Risk.status == "Open")
    if project_id:
        q = q.filter(Risk.project_id == project_id)
    # Sort by computed score (probability * impact) descending
    risks = q.all()
    risks.sort(key=lambda r: r.risk_score, reverse=True)
    return risks[:limit]


@router.post("", response_model=RiskOut, status_code=201)
def create_risk(data: RiskCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    risk = Risk(**data.model_dump())
    db.add(risk)
    db.commit()
    db.refresh(risk)
    return risk


@router.get("/{risk_id}", response_model=RiskOut)
def get_risk(risk_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    risk = db.query(Risk).filter(Risk.id == risk_id).first()
    if not risk:
        raise HTTPException(404, "Risk not found")
    return risk


@router.put("/{risk_id}", response_model=RiskOut)
def update_risk(risk_id: int, data: RiskUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    risk = db.query(Risk).filter(Risk.id == risk_id).first()
    if not risk:
        raise HTTPException(404, "Risk not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(risk, k, v)
    db.commit()
    db.refresh(risk)
    return risk


@router.delete("/{risk_id}", status_code=204)
def delete_risk(risk_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    risk = db.query(Risk).filter(Risk.id == risk_id).first()
    if not risk:
        raise HTTPException(404, "Risk not found")
    db.delete(risk)
    db.commit()
