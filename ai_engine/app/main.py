"""
AI Engine FastAPI Application
ML Prediction Service for Pipeline Lifetime Forecasting
"""
import logging
from fastapi import FastAPI, HTTPException, status
from fastapi.middleware.cors import CORSMiddleware
from app.schemas import PredictionRequest, PredictionResponse
from app.services.predictor import PipeLifetimePredictor

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

app = FastAPI(
    title="Tutas Ai AI Engine",
    description="ML Prediction Service for Pipeline Lifetime Forecasting",
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

# Initialize predictor
predictor = PipeLifetimePredictor()


@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-engine",
        "model": "hybrid-prophet-lstm-v1.0",
    }


@app.post("/predict", response_model=PredictionResponse, status_code=status.HTTP_200_OK)
async def predict_lifetime(request: PredictionRequest) -> PredictionResponse:
    """
    Predict pipe lifetime for next 5 years
    
    Uses hybrid model combining Prophet (time series forecasting) and LSTM
    (non-linear pattern learning) to forecast wall thickness degradation.
    
    - If >= 5 data points: Uses full hybrid model (40% Prophet + 60% LSTM)
    - If 3-4 data points: Uses Prophet only
    - Otherwise: Uses theoretical degradation rates
    
    Args:
        request: PredictionRequest with pipe characteristics and history
        
    Returns:
        PredictionResponse with yearly predictions for 5 years
        
    Raises:
        HTTPException 400: If request validation fails
    """
    try:
        logger.info(f"Prediction request for pipe_id: {request.pipe_id}")
        
        # Generate predictions
        predictions = predictor.predict(request)
        
        # Calculate overall confidence score
        # Higher confidence if we have more historical data
        history_confidence = min(len(request.history_measurements) / 10.0, 1.0)
        base_confidence = 0.7
        confidence_score = base_confidence + (history_confidence * 0.3)
        
        logger.info(
            f"Prediction completed for pipe_id: {request.pipe_id}, "
            f"confidence: {confidence_score:.2f}"
        )
        
        return PredictionResponse(
            pipe_id=request.pipe_id,
            predictions=predictions,
            model_version="hybrid-prophet-lstm-v1.0",
            confidence_score=round(confidence_score, 2),
        )
        
    except Exception as e:
        logger.error(f"Prediction error for pipe_id: {request.pipe_id}, error: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Prediction failed: {str(e)}"
        )


@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "Tutas Ai AI Engine",
        "version": "0.1.0",
        "model": "hybrid-prophet-lstm-v1.0",
        "docs": "/docs",
    }
