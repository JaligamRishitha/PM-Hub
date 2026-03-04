from sqlalchemy import Column, Integer, String, ForeignKey, DateTime, Text, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class SimulationSession(Base):
    __tablename__ = "simulation_sessions"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    created_by = Column(Integer, ForeignKey("users.id"), nullable=False)
    name = Column(String(255), nullable=False, default="Untitled Simulation")
    status = Column(String(50), default="Draft")  # Draft / Applied / Discarded
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    project = relationship("Project")
    creator = relationship("User")
    scenarios = relationship(
        "SimulationScenario",
        back_populates="session",
        cascade="all, delete-orphan",
    )


class SimulationScenario(Base):
    __tablename__ = "simulation_scenarios"

    id = Column(Integer, primary_key=True, index=True)
    simulation_session_id = Column(
        Integer,
        ForeignKey("simulation_sessions.id", ondelete="CASCADE"),
        nullable=False,
    )
    type = Column(String(50), nullable=False)  # Schedule / Cost / Cashflow / LD / Resource
    input_parameters = Column(Text, nullable=False, default="{}")  # JSON string
    output_results = Column(Text, nullable=False, default="{}")  # JSON string
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    session = relationship("SimulationSession", back_populates="scenarios")
