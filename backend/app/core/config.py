"""
Application Configuration
"""
from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    """Application settings from environment variables"""
    
    # Database
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/tutas_ai"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/0"
    REDIS_PASSWORD: Optional[str] = None
    
    # MinIO
    MINIO_ENDPOINT: str = "localhost:9000"
    MINIO_ACCESS_KEY: str = "minioadmin"
    MINIO_SECRET_KEY: str = "minioadmin"
    MINIO_BUCKET_PHOTOS: str = "tutas-photos"
    MINIO_BUCKET_REPORTS: str = "tutas-reports"
    MINIO_USE_SSL: bool = False
    
    # Application
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "INFO"
    
    # AI Engine
    AI_ENGINE_URL: str = "http://ai-engine:8001"
    AI_ENGINE_TIMEOUT: int = 30  # seconds
    
    # Local LLM (Ollama)
    OLLAMA_API_URL: str = "http://localhost:11434/api/generate"
    LLM_MODEL: str = "llama3.2"  # llama3.2, llama2, mistral, qwen2.5
    
    # Security
    # IMPORTANT: Change these in production via environment variables!
    SECRET_KEY: str = "change-this-in-production-use-env-var"
    JWT_SECRET_KEY: str = "change-this-in-production-use-env-var"
    JWT_ALGORITHM: str = "HS256"
    JWT_ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    class Config:
        env_file = ".env"
        case_sensitive = True


settings = Settings()
