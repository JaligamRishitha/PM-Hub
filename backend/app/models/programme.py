from sqlalchemy import Column, Integer, String, Date, DateTime, Text, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class Programme(Base):
    __tablename__ = "programmes"

    id = Column(Integer, primary_key=True, index=True)
    organization_id = Column(Integer, ForeignKey("organizations.id", ondelete="CASCADE"), nullable=False)
    name = Column(String(255), nullable=False)
    code = Column(String(50), unique=True, nullable=False)
    description = Column(Text)
    status = Column(String(50), default="Active")
    start_date = Column(Date)
    end_date = Column(Date)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    organization = relationship("Organization", back_populates="programmes")
    projects = relationship("Project", back_populates="programme", cascade="all, delete-orphan")
