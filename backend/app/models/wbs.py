from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class WBSItem(Base):
    __tablename__ = "wbs_items"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    parent_id = Column(Integer, ForeignKey("wbs_items.id", ondelete="CASCADE"), nullable=True)
    code = Column(String(50), nullable=False)
    name = Column(String(255), nullable=False)
    level = Column(Integer, default=1)
    sort_order = Column(Integer, default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="wbs_items")
    children = relationship("WBSItem", back_populates="parent", cascade="all, delete-orphan")
    parent = relationship("WBSItem", back_populates="children", remote_side=[id])
    activities = relationship("ProjectActivity", back_populates="wbs_item")
