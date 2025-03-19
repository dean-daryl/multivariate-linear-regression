from fastapi import FastAPI
from pydantic import BaseModel
import pickle
import numpy as np
from fastapi.middleware.cors import CORSMiddleware

# Load model
model = pickle.load(open('model.pkl', 'rb'))

app = FastAPI(
    title="Student Performance Prediction API",
    description="Predicts student performance based on various factors.",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=['*'],  # Allows all origins
    allow_credentials=True,
    allow_methods=['*'],   # Allows all HTTP methods
    allow_headers=['*'],   # Allows all headers
)

# Define expected input schema
class PredictionInput(BaseModel):
    hours_studied: float
    previous_scores: float
    extracurricular_activities: float
    sleep_hours: float
    sample_question_papers_practiced: float


@app.post('/predict', tags=["Prediction"])
def predict(data: PredictionInput):
    """
    Predicts a student's performance index based on the given input features.
    
    **Input JSON Example**:
    ```json
    {
        "hours_studied": 5,
        "previous_scores": 80,
        "extracurricular_activities": 2,
        "sleep_hours": 7,
        "sample_question_papers_practiced": 3
    }
    ```
    **Output Example**:
    ```json
    {
        "Performance Index": 75.3
    }
    ```
    """
    # Convert input data to a NumPy array
    X_input = np.array([
        data.hours_studied,
        data.previous_scores,
        data.extracurricular_activities,
        data.sleep_hours,
        data.sample_question_papers_practiced
    ]).reshape(1, -1)

    # Make prediction
    prediction = model.predict(X_input)

    return {"Performance Index": round(float(prediction[0]), 2)}


@app.get("/", tags=["Docs"])
def root():
    """
    Root endpoint. Redirects to Swagger UI for API documentation.
    """
    return {
        "message": "Welcome to the Student Performance Prediction API!",
        "docs_url": "/docs",
        "redoc_url": "/redoc"
    }

# Run the API with uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
