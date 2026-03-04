from sqlalchemy import Column, Integer, String, DateTime, Text, ForeignKey, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class Document(Base):
    __tablename__ = "documents"

    id = Column(Integer, primary_key=True, index=True)
    project_id = Column(Integer, ForeignKey("projects.id", ondelete="CASCADE"), nullable=False)
    doc_code = Column(String(100), nullable=False)
    title = Column(String(255), nullable=False)
    category = Column(String(100), nullable=False)  # Drawing / Specification / Report / Contract / Correspondence
    revision = Column(String(20), default="A")
    status = Column(String(50), default="Draft")  # Draft / Under Review / Approved / Superseded
    file_path = Column(Text)
    file_size = Column(Integer)
    uploaded_by = Column(String(255))
    upload_date = Column(DateTime(timezone=True), server_default=func.now())
    description = Column(Text)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    project = relationship("Project", back_populates="documents")
