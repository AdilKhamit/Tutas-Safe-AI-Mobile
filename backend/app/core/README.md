# Core Module

Core configuration and infrastructure components.

## Components

### config.py
Application settings loaded from environment variables.

### database.py
SQLAlchemy async database configuration and session management.

### ai_client.py
HTTP client for communication with AI Engine microservice.

**Features:**
- Async HTTP requests using httpx
- Timeout handling
- Error handling (ConnectionError, TimeoutException, HTTPStatusError)
- Graceful degradation (returns None if AI Engine unavailable)
- Singleton pattern for client reuse

**Usage:**
```python
from app.core.ai_client import get_ai_client

ai_client = get_ai_client()
prediction = await ai_client.predict_lifespan(
    pipe_id=uuid,
    material="steel",
    age_years=15,
    current_wall_thickness=20.5,
    corrosion_rate_historical=0.3,
)
```
