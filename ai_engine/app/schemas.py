"""
Pydantic schemas for AI Engine API
"""
import uuid
from datetime import date
from typing import List, Optional
from pydantic import BaseModel, Field, field_validator


class MeasurementHistory(BaseModel):
    """Historical measurement data point"""
    date: date
    value: float
    unit: str = "mm"


class PredictionRequest(BaseModel):
    """Request schema for pipe lifetime prediction"""
    pipe_id: uuid.UUID
    material: str = Field(..., description="Pipe material (e.g., 'steel', 'cast_iron')")
    age_years: int = Field(..., ge=0, description="Current age of pipe in years")
    current_wall_thickness: float = Field(..., gt=0, description="Current wall thickness in mm")
    corrosion_rate_historical: float = Field(
        ..., 
        ge=0, 
        description="Historical average corrosion rate (mm/year)"
    )
    history_measurements: List[MeasurementHistory] = Field(
        default_factory=list,
        description="Historical measurement data"
    )
    soil_type: Optional[str] = Field(None, description="Soil type for environmental factors")
    operating_pressure: Optional[float] = Field(None, gt=0, description="Operating pressure (bar)")


class YearlyPrediction(BaseModel):
    """Prediction for a single year"""
    year: int = Field(..., ge=1, le=5, description="Year number (1-5)")
    predicted_thickness: float = Field(..., gt=0, description="Predicted wall thickness (mm)")
    conf_lower: float = Field(..., gt=0, description="Lower confidence bound (mm)")
    conf_upper: float = Field(..., gt=0, description="Upper confidence bound (mm)")
    failure_probability: float = Field(
        ..., 
        ge=0.0, 
        le=1.0, 
        description="Probability of failure (0.0 - 1.0)"
    )
    status: str = Field(..., description="Status: 'Ok', 'Warning', or 'Critical'")

    @field_validator('status')
    @classmethod
    def validate_status(cls, v: str) -> str:
        allowed = ['Ok', 'Warning', 'Critical']
        if v not in allowed:
            raise ValueError(f'Status must be one of {allowed}')
        return v


class PredictionResponse(BaseModel):
    """Response schema for prediction endpoint"""
    pipe_id: uuid.UUID
    predictions: List[YearlyPrediction]
    model_version: str = "hybrid-prophet-lstm-v1.0"
    confidence_score: float = Field(..., ge=0.0, le=1.0, description="Overall model confidence")
