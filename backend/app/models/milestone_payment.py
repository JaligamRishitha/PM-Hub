from sqlalchemy import Column, Integer, String, Numeric, Date, ForeignKey, DateTime, func
from sqlalchemy.orm import relationship

from app.core.database import Base


class MilestonePayment(Base):
    __tablename__ = "milestone_payments"

    id = Column(Integer, primary_key=True, index=True)
    milestone_id = Column(Integer, ForeignKey("milestones.id", ondelete="CASCADE"), nullable=False)
    payment_percentage = Column(Numeric(5, 2), nullable=False)
    payment_value = Column(Numeric(15, 2), nullable=False)
    invoice_number = Column(String(100), nullable=True)
    invoice_date = Column(Date, nullable=True)
    payment_status = Column(String(50), default="Pending")  # Pending / Received
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(
        DateTime(timezone=True), server_default=func.now(), onupdate=func.now()
    )

    milestone = relationship("Milestone", back_populates="payments")
