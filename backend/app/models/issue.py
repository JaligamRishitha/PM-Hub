from sqlalchemy import Column, Integer, String, Date, DateTime, Text, ForeignKey, func
from sqlalchemy.orm import relationship
from sqlalchemy.ext.hybrid import hybrid_property
from datetime import date

from app.core.database import Base


class Issue(Base):
    __tablename__ = "issue_log"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    issue_code = Column(String(50), nullable=False)
    title = Column(String(255), nullable=False)
    description = Column(Text)
    priority = Column(String(50), default="Medium")  # Critical / High / Medium / Low
    assigned_to = Column(String(255))
    raised_by = Column(String(255))
    raised_date = Column(Date, server_default=func.current_date())
    due_date = Column(Date)
    resolution_date = Column(Date)
    resolution_notes = Column(Text)
    status = Column(String(50), default="Open")  # Open / In Progress / Resolved / Closed
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="issues")

    @hybrid_property
    def is_overdue(self) -> bool:
        if self.due_date and self.status in ("Open", "In Progress"):
            return date.today() > self.due_date
        return False
