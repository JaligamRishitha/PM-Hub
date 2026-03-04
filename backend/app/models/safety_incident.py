from sqlalchemy import Column, Integer, String, Date, DateTime, Numeric, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class SafetyIncident(Base):
    __tablename__ = "safety_incidents"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    incident_type = Column(String(255), nullable=False)  # Injury / Near Miss / Observation / Environmental
    severity = Column(String(50), nullable=False)  # Minor / Moderate / Major / Critical
    reported_date = Column(Date, nullable=False)
    resolved_date = Column(Date, nullable=True)
    status = Column(String(50), default="Open")  # Open / Under Investigation / Resolved / Closed
    penalty_cost = Column(Numeric(12, 2), default=0)
    description = Column(String(1000), nullable=True)
    lost_time_hours = Column(Numeric(8, 2), default=0)
    location = Column(String(255))
    reported_by = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="safety_incidents")
