"""
AI Engine HTTP Client
Handles communication with AI Engine microservice
"""
import logging
import uuid
from datetime import date, datetime, timedelta
from typing import Optional
import httpx
from app.core.config import settings

logger = logging.getLogger(__name__)


class AIClient:
    """HTTP client for AI Engine microservice"""
    
    def __init__(self, base_url: Optional[str] = None, timeout: int = 30):
        """
        Initialize AI Client
        
        Args:
            base_url: AI Engine base URL (defaults to settings.AI_ENGINE_URL)
            timeout: Request timeout in seconds
        """
        self.base_url = base_url or settings.AI_ENGINE_URL
        self.timeout = timeout
        self._client: Optional[httpx.AsyncClient] = None
    
    async def __aenter__(self):
        """Async context manager entry"""
        self._client = httpx.AsyncClient(
            base_url=self.base_url,
            timeout=self.timeout,
        )
        return self
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        """Async context manager exit"""
        if self._client:
            await self._client.aclose()
    
    def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client"""
        if self._client is None:
            self._client = httpx.AsyncClient(
                base_url=self.base_url,
                timeout=self.timeout,
            )
        return self._client
    
    async def predict_lifespan(
        self,
        pipe_id: uuid.UUID,
        material: str,
        age_years: int,
        current_wall_thickness: float,
        corrosion_rate_historical: float,
        history_measurements: Optional[list] = None,
    ) -> Optional[dict]:
        """
        Request lifetime prediction from AI Engine
        
        Args:
            pipe_id: Pipe UUID
            material: Pipe material
            age_years: Current age in years
            current_wall_thickness: Current wall thickness in mm
            corrosion_rate_historical: Historical corrosion rate (mm/year)
            history_measurements: List of historical measurements
            
        Returns:
            Prediction response dict or None if AI Engine is unavailable
        """
        client = self._get_client()
        
        # Prepare request payload
        payload = {
            "pipe_id": str(pipe_id),
            "material": material or "steel",  # Default if None
            "age_years": age_years or 0,
            "current_wall_thickness": current_wall_thickness,
            "corrosion_rate_historical": corrosion_rate_historical or 0.1,
            "history_measurements": history_measurements or [],
        }
        
        try:
            logger.info(f"Requesting prediction from AI Engine for pipe_id: {pipe_id}")
            
            response = await client.post(
                "/predict",
                json=payload,
            )
            response.raise_for_status()
            
            result = response.json()
            logger.info(f"AI Engine prediction received for pipe_id: {pipe_id}")
            return result
            
        except httpx.TimeoutException:
            logger.error(
                f"AI Engine timeout for pipe_id: {pipe_id}. "
                f"Service may be unavailable."
            )
            return None
            
        except httpx.ConnectError:
            logger.error(
                f"AI Engine connection error for pipe_id: {pipe_id}. "
                f"Service may be down."
            )
            return None
            
        except httpx.HTTPStatusError as e:
            logger.error(
                f"AI Engine HTTP error for pipe_id: {pipe_id}. "
                f"Status: {e.response.status_code}, Response: {e.response.text}"
            )
            return None
            
        except Exception as e:
            logger.error(
                f"Unexpected error calling AI Engine for pipe_id: {pipe_id}: {str(e)}"
            )
            return None
    
    async def close(self):
        """Close HTTP client"""
        if self._client:
            await self._client.aclose()
            self._client = None


# Singleton instance (will be initialized in dependency injection)
_ai_client_instance: Optional[AIClient] = None


def get_ai_client() -> AIClient:
    """Get singleton AI client instance"""
    global _ai_client_instance
    if _ai_client_instance is None:
        _ai_client_instance = AIClient()
    return _ai_client_instance
