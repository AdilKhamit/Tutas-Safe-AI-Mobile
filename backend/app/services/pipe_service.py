"""
Service layer for Pipe business logic
"""
import logging
import uuid
from datetime import datetime, timedelta
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc
from app.models.pipes import Pipe
from app.models.measurements import Measurement
from app.core.ai_client import AIClient, get_ai_client

logger = logging.getLogger(__name__)

# Cache prediction for 30 days
PREDICTION_CACHE_DAYS = 30


async def get_pipe_by_qr(
    db: AsyncSession,
    qr_code: str,
    ai_client: Optional[AIClient] = None,
) -> Optional[Pipe]:
    """
    Get pipe by QR code with AI prediction update.
    
    If pipe has no recent prediction (or older than 30 days),
    requests new prediction from AI Engine and updates risk_score
    and predicted_lifetime_years.
    
    Args:
        db: Database session
        qr_code: QR code string (format: PL-{COMPANY}-{ID})
        ai_client: AI Client instance (optional, will use singleton if not provided)
        
    Returns:
        Pipe object or None if not found
    """
    stmt = select(Pipe).where(Pipe.qr_code == qr_code)
    result = await db.execute(stmt)
    pipe = result.scalar_one_or_none()
    
    if pipe is None:
        return None
    
    # Check if prediction needs update
    needs_prediction = _should_update_prediction(pipe)
    
    if needs_prediction:
        logger.info(f"Updating AI prediction for pipe_id: {pipe.id}, qr_code: {qr_code}")
        
        # Get AI client
        client = ai_client or get_ai_client()
        
        # Get historical measurements for AI
        history_measurements = await _get_measurement_history(db, pipe.id)
        
        # Calculate age in years
        age_years = _calculate_age_years(pipe.production_date)
        
        # Calculate historical corrosion rate
        corrosion_rate = await _calculate_corrosion_rate(db, pipe.id, pipe.wall_thickness_mm)
        
        # Request prediction from AI Engine
        prediction = await client.predict_lifespan(
            pipe_id=pipe.id,
            material=pipe.material or "steel",
            age_years=age_years,
            current_wall_thickness=pipe.wall_thickness_mm or 20.0,
            corrosion_rate_historical=corrosion_rate,
            history_measurements=history_measurements,
        )
        
        if prediction:
            # Extract risk score and predicted lifetime from AI response
            risk_score, predicted_lifetime = _extract_prediction_metrics(prediction)
            
            # Update pipe with new prediction
            pipe.risk_score = risk_score
            pipe.predicted_lifetime_years = predicted_lifetime
            pipe.updated_at = datetime.utcnow()
            
            await db.commit()
            await db.refresh(pipe)
            
            logger.info(
                f"AI prediction updated for pipe_id: {pipe.id}, "
                f"risk_score: {risk_score}, predicted_lifetime: {predicted_lifetime}"
            )
        else:
            logger.warning(
                f"AI Engine unavailable for pipe_id: {pipe.id}. "
                f"Returning existing data."
            )
    
    return pipe


async def get_pipe_by_id(db: AsyncSession, pipe_id: uuid.UUID) -> Optional[Pipe]:
    """
    Get pipe by UUID.
    
    Args:
        db: Database session
        pipe_id: Pipe UUID
        
    Returns:
        Pipe object or None if not found
    """
    stmt = select(Pipe).where(Pipe.id == pipe_id)
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


def _should_update_prediction(pipe: Pipe) -> bool:
    """
    Check if pipe prediction needs update.
    
    Returns True if:
    - No risk_score or predicted_lifetime_years
    - Last update was more than PREDICTION_CACHE_DAYS ago
    """
    if pipe.risk_score is None or pipe.predicted_lifetime_years is None:
        return True
    
    if pipe.updated_at is None:
        return True
    
    days_since_update = (datetime.utcnow() - pipe.updated_at).days
    return days_since_update > PREDICTION_CACHE_DAYS


def _calculate_age_years(production_date) -> int:
    """Calculate pipe age in years"""
    if production_date is None:
        return 0
    
    if isinstance(production_date, datetime):
        age = datetime.utcnow() - production_date
    else:
        # Assume it's a date object
        age = datetime.utcnow().date() - production_date
    
    return max(0, age.days // 365)


async def _get_measurement_history(
    db: AsyncSession,
    pipe_id: uuid.UUID,
    limit: int = 20,
) -> list:
    """
    Get historical measurements for pipe.
    
    Returns list formatted for AI Engine API.
    """
    stmt = (
        select(Measurement)
        .where(Measurement.pipe_id == pipe_id)
        .order_by(desc(Measurement.measured_at))
        .limit(limit)
    )
    result = await db.execute(stmt)
    measurements = result.scalars().all()
    
    history = []
    for m in measurements:
        history.append({
            "date": m.measured_at.date().isoformat() if m.measured_at else None,
            "value": float(m.value),
            "unit": m.unit,
        })
    
    return history


async def _calculate_corrosion_rate(
    db: AsyncSession,
    pipe_id: uuid.UUID,
    current_thickness: Optional[float],
) -> float:
    """
    Calculate historical corrosion rate from measurements.
    
    Returns average mm/year degradation rate.
    """
    if current_thickness is None:
        return 0.1  # Default rate
    
    # Get oldest and newest measurements
    stmt = (
        select(Measurement)
        .where(Measurement.pipe_id == pipe_id)
        .order_by(Measurement.measured_at)
    )
    result = await db.execute(stmt)
    measurements = result.scalars().all()
    
    if len(measurements) < 2:
        return 0.1  # Default if not enough data
    
    oldest = measurements[0]
    newest = measurements[-1]
    
    if oldest.measured_at is None or newest.measured_at is None:
        return 0.1
    
    time_diff_years = (newest.measured_at - oldest.measured_at).days / 365.0
    
    if time_diff_years <= 0:
        return 0.1
    
    thickness_diff = float(oldest.value) - float(newest.value)
    rate = thickness_diff / time_diff_years
    
    # Ensure positive rate (corrosion = thickness decrease)
    return max(0.0, rate) if rate > 0 else 0.1


def _extract_prediction_metrics(prediction_response: dict) -> tuple[Optional[float], Optional[int]]:
    """
    Extract risk_score and predicted_lifetime_years from AI prediction response.
    
    Args:
        prediction_response: Response from AI Engine
        
    Returns:
        Tuple of (risk_score, predicted_lifetime_years)
    """
    predictions = prediction_response.get("predictions", [])
    
    if not predictions:
        return None, None
    
    # Use first year prediction for risk score
    first_prediction = predictions[0]
    risk_score = first_prediction.get("failure_probability")
    
    # Calculate predicted lifetime: find first year with Critical status
    # or use 5 years if all Ok
    predicted_lifetime = 5  # Default
    
    for pred in predictions:
        if pred.get("status") == "Critical":
            predicted_lifetime = pred.get("year", 5)
            break
        elif pred.get("status") == "Warning":
            # If warning, lifetime is at least this year
            predicted_lifetime = max(predicted_lifetime, pred.get("year", 5))
    
    return risk_score, predicted_lifetime
