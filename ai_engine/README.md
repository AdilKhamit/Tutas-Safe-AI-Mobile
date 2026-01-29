# Tutas Ai AI Engine

ML Prediction Service for Pipeline Lifetime Forecasting using **Hybrid Model (Prophet + LSTM)**.

## Architecture

### Hybrid Model

The AI Engine uses a combination of two models:

- **Prophet (40%)**: Time series forecasting with trend analysis and confidence intervals
- **LSTM (60%)**: Non-linear pattern learning using PyTorch neural networks
- **Ensemble**: `Final = 0.4 * Prophet + 0.6 * LSTM`

### Prediction Logic

1. **Data Preparation**: Convert historical measurements to time series format
2. **Model Selection**:
   - If ≥5 data points: Uses full hybrid model (Prophet + LSTM)
   - If 3-4 data points: Uses Prophet only (not enough data for LSTM)
   - Otherwise: Uses theoretical degradation rate
3. **Prophet Forecasting**: 
   - Fits time series model with trend analysis
   - Projects future values with confidence intervals
4. **LSTM Training**:
   - Trains neural network on historical sequences
   - Learns non-linear acceleration patterns
   - Extrapolates future degradation
5. **Ensemble**: Combines both predictions with weighted average
6. **Failure Probability**: Computed using Normal Distribution CDF
7. **Status Classification**:
   - `Ok`: Risk < 30%, thickness > 18mm
   - `Warning`: Risk 30-80%, thickness 14-18mm
   - `Critical`: Risk > 80% or thickness < 14mm

## API Endpoints

### POST `/predict`

Generate 5-year prediction for pipe lifetime.

**Request:**
```json
{
  "pipe_id": "uuid",
  "material": "steel",
  "age_years": 15,
  "current_wall_thickness": 20.5,
  "corrosion_rate_historical": 0.3,
  "history_measurements": [
    {"date": "2023-01-01", "value": 21.0, "unit": "mm"}
  ]
}
```

**Response:**
```json
{
  "pipe_id": "uuid",
  "predictions": [
    {
      "year": 1,
      "predicted_thickness": 20.1,
      "conf_lower": 19.6,
      "conf_upper": 20.6,
      "failure_probability": 0.05,
      "status": "Ok"
    }
  ],
  "model_version": "hybrid-prophet-lstm-v1.0",
  "confidence_score": 0.85
}
```

## Development

```bash
# Install dependencies
pip install -r requirements.txt

# Run locally
uvicorn app.main:app --host 0.0.0.0 --port 8001 --reload
```

## Docker

```bash
# Build
docker build -t tutas-ai-engine .

# Run
docker run -p 8001:8001 tutas-ai-engine
```

## Model Parameters

- **Critical Threshold**: 14.0 mm
- **Warning Threshold**: 18.0 mm
- **Critical Risk**: > 80%
- **Warning Risk**: > 30%
- **Minimum Training Data**: 
  - Hybrid model: 5 points
  - Prophet only: 3 points
  - Fallback: < 3 points

## Material Factors

- Stainless Steel: 0.3x corrosion rate
- Steel: 1.0x (baseline)
- Cast Iron: 1.2x
- Ductile Iron: 0.9x
- PVC/HDPE: 0.1x

## Technical Details

### Prophet Model
- Uses Facebook Prophet for time series forecasting
- Handles trend and seasonality
- Provides confidence intervals based on historical variance

### LSTM Model
- PyTorch-based neural network
- Architecture: 1 input → 16 hidden → 1 output
- Sequence length: 3 (uses last 3 measurements to predict next)
- Training: 50 epochs with Adam optimizer
- Learns non-linear degradation patterns

### Ensemble Method
- Weighted combination: 40% Prophet + 60% LSTM
- Prophet provides stable baseline trend
- LSTM captures acceleration and non-linear effects
- Final prediction balances both approaches
