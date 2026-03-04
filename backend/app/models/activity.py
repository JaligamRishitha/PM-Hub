from sqlalchemy import Column, Integer, String, Date, Numeric, Boolean, ForeignKey, DateTime, Text, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base


class ProjectActivity(Base):
    __tablename__ = "project_activities"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    wbs_id = Column(Integer, ForeignKey("wbs_items.id", ondelete="SET NULL"), nullable=True)
    activity_code = Column(String(50))
    activity_name = Column(String(255), nullable=False)
    phase = Column(String(50), nullable=False)
    planned_start = Column(Date, nullable=False)
    planned_finish = Column(Date, nullable=False)
    actual_start = Column(Date, nullable=True)
    actual_finish = Column(Date, nullable=True)
    completion_pct = Column(Numeric(5, 2), default=0)
    is_milestone = Column(Boolean, default=False)
    is_critical = Column(Boolean, default=False)
    predecessor_ids = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="activities")
    wbs_item = relationship("WBSItem", back_populates="activities")

    @hybrid_property
    def status(self) -> str:
        if self.completion_pct is not None and float(self.completion_pct) >= 100:
            return "Completed"
        if self.actual_finish and self.planned_finish and self.actual_finish > self.planned_finish:
            return "Delayed"
        if self.actual_start and not self.actual_finish:
            if self.planned_finish:
                from datetime import date
                if date.today() > self.planned_finish:
                    return "Delayed"
            return "In Progress"
        if not self.actual_start:
            if self.planned_start:
                from datetime import date
                if date.today() > self.planned_start:
                    return "Delayed"
            return "Not Started"
        return "On Time"

    @hybrid_property
    def delay_days(self) -> int:
        from datetime import date
        if self.actual_finish and self.planned_finish:
            delta = (self.actual_finish - self.planned_finish).days
            return max(delta, 0)
        if not self.actual_finish and self.planned_finish:
            delta = (date.today() - self.planned_finish).days
            return max(delta, 0)
        return 0
