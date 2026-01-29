"""
Pydantic schemas for Pipe model
"""
import uuid
from datetime import date
from pydantic import BaseModel, ConfigDict, computed_field
from typing import Optional


class PipeBase(BaseModel):
    """Base schema for Pipe"""
    qr_code: str
    manufacturer: Optional[str] = None
    production_date: Optional[date] = None
    material: Optional[str] = None
    diameter_mm: Optional[int] = None
    wall_thickness_mm: Optional[float] = None
    length_meters: Optional[float] = None


class PipeResponse(PipeBase):
    """Response schema for Pipe with computed fields"""
    id: uuid.UUID
    current_status: str
    risk_score: Optional[float] = None
    predicted_lifetime_years: Optional[int] = None
    
    # Геометрия: упрощаем для клиента
    @computed_field
    @property
    def location(self) -> Optional[dict[str, float]]:
        """
        Extract location from PostGIS Geography.
        Returns dict with 'lat' and 'lon' or None.
        Note: Actual conversion from WKBElement will be handled in service layer.
        """
        # This will be populated from the service layer
        # For now, return None - will be set via model_validate with from_attributes
        return None
    
    @computed_field
    @property
    def next_inspection_date(self) -> Optional[date]:
        """
        Computed field for next inspection date.
        Will be calculated from latest inspection.
        """
        return None

    model_config = ConfigDict(from_attributes=True)


class PipeQRRequest(BaseModel):
    """Request schema for QR code lookup"""
    qr_code: str


class PipeCreate(PipeBase):
    """Schema for creating a new pipe"""
    company: Optional[str] = "COMPANY"  # Company name for QR code generation
    # qr_code will be auto-generated if not provided
    qr_code: Optional[str] = None
