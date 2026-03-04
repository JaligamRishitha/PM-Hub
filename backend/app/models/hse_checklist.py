from sqlalchemy import Column, Integer, String, Date, DateTime, Text, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class HSEChecklist(Base):
    __tablename__ = "hse_checklist"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    checklist_item = Column(String(500), nullable=False)
    category = Column(String(100))
    status = Column(String(50), default="Pending")  # Pending / In Progress / Completed / Failed
    last_inspection_date = Column(Date, nullable=True)
    inspector = Column(String(255))
    notes = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="hse_checklists")
