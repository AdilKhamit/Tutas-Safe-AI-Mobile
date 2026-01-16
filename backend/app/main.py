"""
FastAPI Application Entry Point
"""
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

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
