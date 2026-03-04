from sqlalchemy import Column, Integer, String, Date, DateTime, Numeric, Text, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class Project(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True, index=True)
    programme_id = Column(Integer, ForeignKey("programmes.id", ondelete="SET NULL"), nullable=True)
    name = Column(String(255), nullable=False)
    code = Column(String(50))
    client = Column(String(255), nullable=False)
    description = Column(Text)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=False)
    contract_completion_date = Column(Date)
    actual_completion_date = Column(Date)
    status = Column(String(50), default="Active")
    total_budget = Column(Numeric(15, 2), default=0)
    contract_value = Column(Numeric(15, 2), default=0)
    forecast_cost = Column(Numeric(15, 2), default=0)
    daily_ld_rate = Column(Numeric(12, 2), default=0)
    ld_cap_pct = Column(Numeric(5, 2), default=10.00)
    phase = Column(String(50), default="Gate B")
    location = Column(String(255))
    project_manager = Column(String(255))
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    programme = relationship("Programme", back_populates="projects")
    activities = relationship("ProjectActivity", back_populates="project", cascade="all, delete-orphan")
    milestones = relationship("Milestone", back_populates="project", cascade="all, delete-orphan")
    wbs_items = relationship("WBSItem", back_populates="project", cascade="all, delete-orphan")
    cbs_items = relationship("CBS", back_populates="project", cascade="all, delete-orphan")
    compensation_events = relationship("CompensationEvent", back_populates="project", cascade="all, delete-orphan")
    variations = relationship("ApprovedVariation", back_populates="project", cascade="all, delete-orphan")
    risks = relationship("Risk", back_populates="project", cascade="all, delete-orphan")
    issues = relationship("Issue", back_populates="project", cascade="all, delete-orphan")
    safety_incidents = relationship("SafetyIncident", back_populates="project", cascade="all, delete-orphan")
    hse_checklists = relationship("HSEChecklist", back_populates="project", cascade="all, delete-orphan")
    documents = relationship("Document", back_populates="project", cascade="all, delete-orphan")
