"""
Defect model - Pipeline defects with AI detection
"""
import uuid
from sqlalchemy import String, Integer, Numeric, ForeignKey, Boolean, Text
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from geoalchemy2 import Geography
from .base import Base, UUIDMixin, TimestampMixin


class Defect(Base, UUIDMixin, TimestampMixin):
    """Pipeline defect record with AI detection"""
    __tablename__ = "defects"

    inspection_id: Mapped[uuid.UUID | None] = mapped_column(ForeignKey("inspections.id"), nullable=True)
    pipe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pipes.id"), nullable=False)

    # Классификация
    defect_type: Mapped[str] = mapped_column(String(100))
    severity_level: Mapped[int] = mapped_column(Integer)  # 1-5

    # Геометрия
    gps_coordinates: Mapped[object] = mapped_column(Geography("POINT", srid=4326), nullable=True)
    location_on_pipe: Mapped[str | None] = mapped_column(String(50))  # "12 часов"

    # Размеры
    length_mm: Mapped[float | None] = mapped_column(Numeric(8, 2))
    depth_mm: Mapped[float | None] = mapped_column(Numeric(8, 2))
    
    # AI поля
    ai_detected: Mapped[bool] = mapped_column(Boolean, default=False)
    ai_confidence: Mapped[float | None] = mapped_column(Numeric(3, 2))
    photos: Mapped[list | None] = mapped_column(JSONB)

    pipe = relationship("Pipe", back_populates="defects")
    inspection = relationship("Inspection", back_populates="defects")
