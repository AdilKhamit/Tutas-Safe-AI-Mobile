"""
Inspection model - Pipeline inspection records
"""
import uuid
from datetime import date, datetime
from sqlalchemy import String, ForeignKey, Date, DateTime, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base, UUIDMixin, TimestampMixin


class Inspection(Base, UUIDMixin, TimestampMixin):
    """Pipeline inspection record"""
    __tablename__ = "inspections"

    pipe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pipes.id"), nullable=False)
    inspection_type: Mapped[str] = mapped_column(String(50))  # visual, ultrasonic, etc.
    
    scheduled_date: Mapped[date | None] = mapped_column(Date)
    completed_date: Mapped[datetime | None] = mapped_column(DateTime)
    
    status: Mapped[str] = mapped_column(String(30), default="planned")
    weather_conditions: Mapped[dict | None] = mapped_column(JSONB)
    equipment_used: Mapped[list | None] = mapped_column(JSONB)
    
    overall_assessment: Mapped[str | None] = mapped_column(String(50))
    recommendations: Mapped[str | None] = mapped_column(Text)

    pipe = relationship("Pipe", back_populates="inspections")
    defects = relationship("Defect", back_populates="inspection", cascade="all, delete-orphan")
