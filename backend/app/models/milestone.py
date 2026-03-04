from sqlalchemy import Column, Integer, String, Date, Boolean, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base


class Milestone(Base):
    __tablename__ = "milestones"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    phase = Column(String(50), nullable=False)
    planned_date = Column(Date, nullable=False)
    actual_date = Column(Date, nullable=True)
    is_critical = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    project = relationship("Project", back_populates="milestones")
    payments = relationship("MilestonePayment", back_populates="milestone", cascade="all, delete-orphan")

    @hybrid_property
    def status(self) -> str:
        if self.actual_date is None:
            return "Pending"
        if self.actual_date > self.planned_date:
            return "Delayed"
        return "Completed"

    @hybrid_property
    def delay_days(self) -> int:
        if self.actual_date and self.planned_date and self.actual_date > self.planned_date:
            return (self.actual_date - self.planned_date).days
        return 0
