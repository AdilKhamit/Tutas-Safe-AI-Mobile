"""
Pipe Lifetime Predictor - Hybrid Model (Prophet + LSTM)
"""
import math
import numpy as np
import pandas as pd
from typing import List, Tuple, Optional, Dict
from datetime import date, datetime, timedelta
from prophet import Prophet
import torch
import torch.nn as nn
from sklearn.metrics import mean_squared_error

from app.schemas import PredictionRequest, YearlyPrediction


class LSTMModel(nn.Module):
    """Simple LSTM for time series prediction"""
    
    def __init__(self, input_size=1, hidden_size=32, num_layers=2, output_size=1):
        super(LSTMModel, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, output_size)
        
    def forward(self, x):
        # x shape: (batch, seq_len, input_size)
        lstm_out, _ = self.lstm(x)
        # Take the last output
        last_output = lstm_out[:, -1, :]
        output = self.fc(last_output)
        return output


class PipeLifetimePredictor:
    """
    Hybrid predictor combining Prophet (time series) and LSTM (non-linear patterns).
    
    Architecture:
    - Prophet (40%): Linear trend projection with confidence intervals
    - LSTM (60%): Non-linear acceleration patterns
    - Ensemble: 0.4 * Prophet + 0.6 * LSTM
    """
    
    # Critical thresholds (mm)
    CRITICAL_THICKNESS = 14.0
    WARNING_THICKNESS = 18.0
    
    # Risk thresholds (probability 0.0 - 1.0)
    CRITICAL_RISK_THRESHOLD = 0.8
    WARNING_RISK_THRESHOLD = 0.3
    
    # Model weights
    PROPHET_WEIGHT = 0.4
    LSTM_WEIGHT = 0.6
    
    def __init__(self):
        """Initialize predictor"""
        self.device = torch.device('cuda' if torch.cuda.is_available() else 'cpu')
    
    def predict(self, features: PredictionRequest) -> List[YearlyPrediction]:
        """
        Generate 5-year prediction using hybrid model.
        
        If enough history data is available (>= 5 points), uses Prophet + LSTM.
        If 3-4 points, uses Prophet only.
        Otherwise, uses theoretical degradation rate.
        """
        predictions = []
        
        # 1. Prepare Data
        df = self._prepare_dataframe(features)
        
        current_age = features.age_years
        current_thickness = features.current_wall_thickness
        
        # 2. Generate predictions based on data availability
        if len(df) >= 5:
            # Full hybrid model
            prophet_pred = self._prophet_predict(df, current_age)
            lstm_pred = self._lstm_predict(df, current_age, current_thickness)
            
            # Ensemble
            for year_offset in range(1, 6):
                future_age = current_age + year_offset
                
                prophet_val = prophet_pred.get(future_age, current_thickness)
                lstm_val = lstm_pred.get(future_age, current_thickness)
                
                predicted_thickness = (
                    self.PROPHET_WEIGHT * prophet_val +
                    self.LSTM_WEIGHT * lstm_val
                )
                
                # Confidence intervals (wider for later years)
                uncertainty = 0.5 + (year_offset * 0.15)
                conf_lower = max(predicted_thickness - uncertainty, 0.1)
                conf_upper = predicted_thickness + uncertainty
                
                failure_prob = self._calculate_failure_probability(
                    predicted_thickness, uncertainty
                )
                
                status = self._determine_status(failure_prob, predicted_thickness)
                
                predictions.append(YearlyPrediction(
                    year=year_offset,
                    predicted_thickness=round(predicted_thickness, 2),
                    conf_lower=round(conf_lower, 2),
                    conf_upper=round(conf_upper, 2),
                    failure_probability=round(failure_prob, 4),
                    status=status
                ))
                
        elif len(df) >= 3:
            # Prophet only (not enough data for LSTM)
            prophet_pred = self._prophet_predict(df, current_age)
            
            for year_offset in range(1, 6):
                future_age = current_age + year_offset
                predicted_thickness = prophet_pred.get(future_age, current_thickness)
                
                uncertainty = 0.6 + (year_offset * 0.2)
                conf_lower = max(predicted_thickness - uncertainty, 0.1)
                conf_upper = predicted_thickness + uncertainty
                
                failure_prob = self._calculate_failure_probability(
                    predicted_thickness, uncertainty
                )
                
                status = self._determine_status(failure_prob, predicted_thickness)
                
                predictions.append(YearlyPrediction(
                    year=year_offset,
                    predicted_thickness=round(predicted_thickness, 2),
                    conf_lower=round(conf_lower, 2),
                    conf_upper=round(conf_upper, 2),
                    failure_probability=round(failure_prob, 4),
                    status=status
                ))
        else:
            # Fallback: Theoretical rate
            material_factor = self._get_material_factor(features.material)
            slope = -1.0 * features.corrosion_rate_historical * material_factor
            
            for year_offset in range(1, 6):
                predicted_thickness = max(
                    current_thickness + (slope * year_offset),
                    0.1
                )
                
                uncertainty = 0.8 * (1 + 0.2 * year_offset)
                conf_lower = max(predicted_thickness - uncertainty, 0.0)
                conf_upper = predicted_thickness + uncertainty
                
                failure_prob = self._calculate_failure_probability(
                    predicted_thickness, uncertainty
                )
                
                status = self._determine_status(failure_prob, predicted_thickness)
                
                predictions.append(YearlyPrediction(
                    year=year_offset,
                    predicted_thickness=round(predicted_thickness, 2),
                    conf_lower=round(conf_lower, 2),
                    conf_upper=round(conf_upper, 2),
                    failure_probability=round(failure_prob, 4),
                    status=status
                ))
        
        return predictions
    
    def _prepare_dataframe(self, features: PredictionRequest) -> pd.DataFrame:
        """Prepare Prophet-compatible dataframe"""
        if not features.history_measurements:
            return pd.DataFrame(columns=['ds', 'y'])
        
        data = []
        today = date.today()
        production_year = today.year - features.age_years
        production_date = date(production_year, 1, 1)
        
        for m in features.history_measurements:
            if m.date < production_date:
                continue
            
            # Prophet expects 'ds' (datetime) and 'y' (value)
            data.append({
                'ds': pd.Timestamp(m.date),
                'y': m.value
            })
        
        if not data:
            return pd.DataFrame(columns=['ds', 'y'])
        
        df = pd.DataFrame(data)
        df = df.sort_values('ds')
        return df
    
    def _prophet_predict(self, df: pd.DataFrame, current_age: int) -> Dict[int, float]:
        """
        Use Prophet for time series forecasting.
        Returns dict: {future_age: predicted_thickness}
        """
        try:
            # Initialize Prophet with conservative settings
            model = Prophet(
                yearly_seasonality=False,
                weekly_seasonality=False,
                daily_seasonality=False,
                changepoint_prior_scale=0.05,  # Conservative trend changes
            )
            
            model.fit(df)
            
            # Create future dataframe (5 years ahead)
            future_dates = []
            last_date = df['ds'].max()
            
            for year_offset in range(1, 6):
                future_date = last_date + pd.Timedelta(days=365 * year_offset)
                future_dates.append(future_date)
            
            future_df = pd.DataFrame({'ds': future_dates})
            
            # Make prediction
            forecast = model.predict(future_df)
            
            # Convert to age-based predictions
            predictions = {}
            for idx, row in forecast.iterrows():
                future_date = row['ds']
                age_at_date = current_age + (idx + 1)
                predictions[age_at_date] = max(row['yhat'], 0.1)
            
            return predictions
            
        except Exception as e:
            # If Prophet fails, return empty dict (will use fallback)
            print(f"Prophet prediction failed: {e}")
            return {}
    
    def _lstm_predict(self, df: pd.DataFrame, current_age: int, current_thickness: float) -> Dict[int, float]:
        """
        Use LSTM for non-linear pattern learning.
        Returns dict: {future_age: predicted_thickness}
        """
        try:
            if len(df) < 5:
                return {}
            
            # Prepare sequence data
            values = df['y'].values.reshape(-1, 1)
            
            # Normalize
            mean_val = values.mean()
            std_val = values.std() + 1e-8
            normalized = (values - mean_val) / std_val
            
            # Create sequences (use last 3 points to predict next)
            seq_length = min(3, len(normalized) - 1)
            if seq_length < 2:
                return {}
            
            # Prepare training data
            X = []
            y = []
            for i in range(len(normalized) - seq_length):
                X.append(normalized[i:i+seq_length])
                y.append(normalized[i+seq_length])
            
            if len(X) < 2:
                return {}
            
            X = np.array(X)
            y = np.array(y)
            
            # Convert to tensors
            X_tensor = torch.FloatTensor(X).to(self.device)
            y_tensor = torch.FloatTensor(y).to(self.device)
            
            # Initialize and train LSTM
            model = LSTMModel(input_size=1, hidden_size=16, num_layers=1).to(self.device)
            criterion = nn.MSELoss()
            optimizer = torch.optim.Adam(model.parameters(), lr=0.01)
            
            # Quick training (50 epochs)
            model.train()
            for epoch in range(50):
                optimizer.zero_grad()
                output = model(X_tensor)
                loss = criterion(output, y_tensor)
                loss.backward()
                optimizer.step()
            
            # Predict future
            model.eval()
            predictions = {}
            
            # Start from last sequence
            last_seq = normalized[-seq_length:].reshape(1, seq_length, 1)
            last_seq_tensor = torch.FloatTensor(last_seq).to(self.device)
            
            current_pred = normalized[-1]
            
            for year_offset in range(1, 6):
                # Predict next value
                with torch.no_grad():
                    pred_tensor = model(last_seq_tensor)
                    current_pred = pred_tensor.cpu().numpy()[0, 0]
                
                # Denormalize
                predicted_thickness = (current_pred * std_val) + mean_val
                predicted_thickness = max(predicted_thickness, 0.1)
                
                future_age = current_age + year_offset
                predictions[future_age] = predicted_thickness
                
                # Update sequence for next prediction
                new_seq = np.append(last_seq[0, :, 0], current_pred)[-seq_length:]
                last_seq = new_seq.reshape(1, seq_length, 1)
                last_seq_tensor = torch.FloatTensor(last_seq).to(self.device)
            
            return predictions
            
        except Exception as e:
            # If LSTM fails, return empty dict
            print(f"LSTM prediction failed: {e}")
            return {}
    
    def _calculate_failure_probability(self, thickness: float, uncertainty: float) -> float:
        """
        Calculate probability that thickness < CRITICAL_THICKNESS
        using Normal Distribution CDF.
        """
        if uncertainty <= 0.001:
            return 1.0 if thickness < self.CRITICAL_THICKNESS else 0.0
        
        z_score = (self.CRITICAL_THICKNESS - thickness) / uncertainty
        prob = 0.5 * (1 + math.erf(z_score / math.sqrt(2)))
        
        return min(max(prob, 0.0), 0.99)
    
    def _determine_status(self, failure_prob: float, thickness: float) -> str:
        """Determine status based on failure probability and thickness"""
        if failure_prob >= self.CRITICAL_RISK_THRESHOLD or thickness < self.CRITICAL_THICKNESS:
            return 'Critical'
        elif failure_prob >= self.WARNING_RISK_THRESHOLD or thickness < self.WARNING_THICKNESS:
            return 'Warning'
        else:
            return 'Ok'
    
    def _get_material_factor(self, material: str) -> float:
        """Material-specific corrosion resistance factor"""
        factors = {
            'stainless_steel': 0.3,
            'steel': 1.0,
            'cast_iron': 1.2,
            'ductile_iron': 0.9,
            'pvc': 0.1,
            'hdp': 0.1,
        }
        return factors.get(material.lower(), 1.0)
