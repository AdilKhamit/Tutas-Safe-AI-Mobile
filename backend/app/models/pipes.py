"""
Pipe model - Digital passport for pipeline segments
"""
from datetime import date
from sqlalchemy import String, Integer, Numeric, Date
from sqlalchemy.orm import Mapped, mapped_column, relationship
from geoalchemy2 import Geography
from .base import Base, UUIDMixin, TimestampMixin


class Pipe(Base, UUIDMixin, TimestampMixin):
    """Digital passport for pipeline segment"""
    __tablename__ = "pipes"

    qr_code: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    
    # Паспортные данные
    manufacturer: Mapped[str | None] = mapped_column(String(200))
    production_date: Mapped[date | None] = mapped_column(Date)
    material: Mapped[str | None] = mapped_column(String(100))
    diameter_mm: Mapped[int | None] = mapped_column(Integer)
    wall_thickness_mm: Mapped[float | None] = mapped_column(Numeric(5, 2))
    length_meters: Mapped[float | None] = mapped_column(Numeric(8, 2))

    # Геолокация (PostGIS)
    route_line: Mapped[object] = mapped_column(Geography("LINESTRING", srid=4326), nullable=True)
    start_point: Mapped[object] = mapped_column(Geography("POINT", srid=4326), nullable=True)
    
    # Эксплуатация и AI
    current_status: Mapped[str] = mapped_column(String(50), default="active")
    risk_score: Mapped[float | None] = mapped_column(Numeric(3, 2))
    predicted_lifetime_years: Mapped[int | None] = mapped_column(Integer)
    
    # Relationships
    inspections = relationship("Inspection", back_populates="pipe", cascade="all, delete-orphan")
    defects = relationship("Defect", back_populates="pipe", cascade="all, delete-orphan")
    measurements = relationship("Measurement", back_populates="pipe", cascade="all, delete-orphan")
