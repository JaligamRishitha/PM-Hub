from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base


class CompensationEvent(Base):
    __tablename__ = "compensation_events"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    event_name = Column(String(255), nullable=False)
    linked_wbs = Column(String(50), nullable=True)
    time_impact_days = Column(Integer, default=0)
    daily_overhead_cost = Column(Numeric(12, 2), default=0)
    status = Column(String(50), default="Pending")  # Pending / Approved / Rejected
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    project = relationship("Project", back_populates="compensation_events")

    @hybrid_property
    def cost_impact(self):
        return int(self.time_impact_days or 0) * float(self.daily_overhead_cost or 0)
