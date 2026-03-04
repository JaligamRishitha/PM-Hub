from sqlalchemy import Column, Integer, String, Date, DateTime, Text, Numeric, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class ApprovedVariation(Base):
    __tablename__ = "approved_variations"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    variation_code = Column(String(50), nullable=False)
    description = Column(Text, nullable=False)
    value = Column(Numeric(15, 2), nullable=False, default=0)
    cost_impact = Column(Numeric(15, 2), default=0)
    schedule_impact_days = Column(Integer, default=0)
    approval_status = Column(String(50), default="Pending")  # Pending / Under Review / Approved / Rejected
    submitted_date = Column(Date)
    approval_date = Column(Date)
    approved_by = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="variations")
