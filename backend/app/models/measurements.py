"""
Measurement model - TimescaleDB hypertable for time-series data
"""
import uuid
from datetime import datetime
from sqlalchemy import String, Numeric, ForeignKey, event
from sqlalchemy.sql import DDL
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship
from .base import Base, UUIDMixin


class Measurement(Base, UUIDMixin):
    """Time-series measurement data (TimescaleDB hypertable)"""
    __tablename__ = "measurements"

    pipe_id: Mapped[uuid.UUID] = mapped_column(ForeignKey("pipes.id"), nullable=False)
    
    measurement_type: Mapped[str] = mapped_column(String(50))  # wall_thickness, pressure, etc.
    value: Mapped[float] = mapped_column(Numeric(10, 4), nullable=False)
    unit: Mapped[str] = mapped_column(String(20), nullable=False)
    
    measured_at: Mapped[datetime] = mapped_column(nullable=False, index=True)
    equipment_info: Mapped[dict | None] = mapped_column(JSONB)

    pipe = relationship("Pipe", back_populates="measurements")


# Автоматическое создание гипертаблицы после создания таблицы в БД
# Only if TimescaleDB extension is available
# Note: Disabled for now - requires TimescaleDB extension
# Uncomment if TimescaleDB is installed:
# trigger_hypertable = DDL(
#     "SELECT create_hypertable('measurements', 'measured_at', if_not_exists => TRUE);"
# )
# event.listen(Measurement.__table__, 'after_create', trigger_hypertable)
