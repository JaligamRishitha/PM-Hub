from sqlalchemy import Column, Integer, String, Numeric, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base


class CBS(Base):
    __tablename__ = "cbs"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    wbs_code = Column(String(50), nullable=False)
    description = Column(String(500), nullable=False)
    budget_cost = Column(Numeric(15, 2), default=0)
    actual_cost = Column(Numeric(15, 2), default=0)
    forecast_cost = Column(Numeric(15, 2), default=0)
    approved_variation = Column(Numeric(15, 2), default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="cbs_items")

    @hybrid_property
    def variance(self):
        budget = float(self.budget_cost or 0)
        actual = float(self.actual_cost or 0)
        variation = float(self.approved_variation or 0)
        return budget + variation - actual
