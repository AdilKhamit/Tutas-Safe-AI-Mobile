"""
FastAPI Application Entry Point
"""
import logging
from fastapi import FastAPI, Request, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from app.api.routes import pipes, chat
from app.core.config import settings

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)

app = FastAPI(
    title="Tutas Ai API",
    description="Enterprise-Grade Pipeline Monitoring and Inspection System",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# CORS Configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Configure appropriately for production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Optional API Key authentication middleware (disabled in development)
API_KEY_REQUIRED = settings.ENVIRONMENT != "development"
# API keys should be set via environment variable API_KEYS (comma-separated)
# Example: API_KEYS=key1,key2,key3
import os
VALID_API_KEYS = [
    key.strip() 
    for key in os.getenv("API_KEYS", "dev-api-key-12345").split(",") 
    if key.strip()
]

@app.middleware("http")
async def api_key_middleware(request: Request, call_next):
    """Optional API key authentication middleware"""
    # Skip authentication for health check and docs
    if request.url.path in ["/health", "/docs", "/redoc", "/openapi.json", "/"]:
        return await call_next(request)
    
    # Skip authentication in development mode
    if not API_KEY_REQUIRED:
        return await call_next(request)
    
    # Check Authorization header
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={
                "success": False,
                "message": "Missing Authorization header. Expected: Authorization: Bearer <api_key>"
            }
        )
    
    # Extract API key from Bearer token
    if not auth_header.startswith("Bearer "):
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={
                "success": False,
                "message": "Invalid Authorization format. Expected: Authorization: Bearer <api_key>"
            }
        )
    
    api_key = auth_header.replace("Bearer ", "").strip()
    
    # Validate API key
    if api_key not in VALID_API_KEYS:
        return JSONResponse(
            status_code=status.HTTP_401_UNAUTHORIZED,
            content={
                "success": False,
                "message": "Invalid API key"
            }
        )
    
    return await call_next(request)

# Include routers
app.include_router(pipes.router, prefix="/api/v1/pipes", tags=["pipes"])
app.include_router(chat.router, prefix="/api/v1", tags=["chat"])


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "service": "backend-api"}


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Tutas Ai API",
        "version": "0.1.0",
        "docs": "/docs",
    }
