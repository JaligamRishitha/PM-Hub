from typing import List

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.security import get_current_user
from app.models import WBSItem
from app.schemas.wbs import WBSCreate, WBSUpdate, WBSOut

router = APIRouter(prefix="/api/wbs", tags=["WBS"])


@router.get("", response_model=List[WBSOut])
def list_wbs(project_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    items = db.query(WBSItem).filter(
        WBSItem.project_id == project_id,
        WBSItem.parent_id == None  # noqa: E711
    ).order_by(WBSItem.sort_order).all()
    return _build_tree(items)


def _build_tree(items):
    result = []
    for item in items:
        node = WBSOut.model_validate(item)
        if item.children:
            node.children = _build_tree(
                sorted(item.children, key=lambda c: c.sort_order)
            )
        result.append(node)
    return result


@router.post("", response_model=WBSOut, status_code=201)
def create_wbs(data: WBSCreate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    wbs = WBSItem(**data.model_dump())
    db.add(wbs)
    db.commit()
    db.refresh(wbs)
    return wbs


@router.put("/{wbs_id}", response_model=WBSOut)
def update_wbs(wbs_id: int, data: WBSUpdate, db: Session = Depends(get_db), _=Depends(get_current_user)):
    wbs = db.query(WBSItem).filter(WBSItem.id == wbs_id).first()
    if not wbs:
        raise HTTPException(404, "WBS item not found")
    for k, v in data.model_dump(exclude_unset=True).items():
        setattr(wbs, k, v)
    db.commit()
    db.refresh(wbs)
    return wbs


@router.delete("/{wbs_id}", status_code=204)
def delete_wbs(wbs_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    wbs = db.query(WBSItem).filter(WBSItem.id == wbs_id).first()
    if not wbs:
        raise HTTPException(404, "WBS item not found")
    db.delete(wbs)
    db.commit()
