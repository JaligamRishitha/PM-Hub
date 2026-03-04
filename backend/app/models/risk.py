from sqlalchemy import Column, Integer, String, Date, DateTime, Text, Numeric, ForeignKey, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property

from app.core.database import Base


class Risk(Base):
    __tablename__ = "risk_register"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    risk_code = Column(String(50), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    category = Column(String(100))
    probability = Column(Integer, nullable=False)  # 1-5
    impact = Column(Integer, nullable=False)  # 1-5
    mitigation_plan = Column(Text)
    contingency_plan = Column(Text)
    owner = Column(String(255))
    status = Column(String(50), default="Open")
    identified_date = Column(Date, server_default=func.current_date())
    review_date = Column(Date)
    cost_exposure = Column(Numeric(15, 2), default=0)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="risks")

    @hybrid_property
    def risk_score(self) -> int:
        return (self.probability or 0) * (self.impact or 0)
