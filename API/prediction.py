from fastapi import FastAPI
from pydantic import BaseModel, Field
import pickle
import numpy as np
from fastapi.middleware.cors import CORSMiddleware

# Load model and scalar

model = pickle.load(open('model.pkl', 'rb'))
scaler = pickle.load(open('scaler.pkl', 'rb'))
ars_model = pickle.load(open('ars_model.pkl', 'rb'))


app = FastAPI()

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],
    allow_credentials=True,
    allow_methods=['*'],
    allow_headers=['*'],
)

class LoadBalancePredictionInput(BaseModel):
    training_hours_per_week: float = Field(..., ge=0, le=40, description="Training hours per week (0-40)")
    recovery_days_per_week: float = Field(..., ge=0, le=7, description="Recovery days per week (0-7)")
    acl_risk_score: float = Field(..., ge=0, le=100, description="ACL Risk Score (0-100)")

class ARSPredictionInput(BaseModel):
    fatigue_score: float = Field(..., ge=0, le=10, description="Fatigue Score (1-9)")

# Endpoint to predict ACL Risk Score
@app.post('/predict-ars')
def predict(data: ARSPredictionInput):
    X_input = np.array([
        data.fatigue_score,
    ]).reshape(1, -1)
  

    prediction = ars_model.predict(X_input)

    return {"ACL Risk Score": float(prediction[0])}

@app.post('/predict-load-balance-score')
def predict(data: LoadBalancePredictionInput):
    X_input = np.array([
        data.training_hours_per_week,
        data.recovery_days_per_week,
        data.acl_risk_score
    ]).reshape(1, -1)
    X_scaled = scaler.transform(X_input)

    prediction = model.predict(X_scaled)

    return {"Load Balance Score": float(prediction[0])}

# Run the API with uvicorn

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)