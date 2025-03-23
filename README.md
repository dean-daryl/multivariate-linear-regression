# Athlete Injury Prediction System

## Mission
Our mission is to reduce sports-related injuries by using data science to predict injury risk and optimize training routines. This system helps athletes and coaches make informed decisions about training intensity and recovery, leading to better performance outcomes while minimizing injury potential.

## How It Works

### Overview
The Athlete Injury Prediction System uses machine learning to analyze training patterns and provide personalized risk assessments. The system evaluates two key metrics:

1. **ACL Injury Risk Score**: Calculates the probability of ACL injury based on fatigue levels
2. **Load Balance Score**: Evaluates overall training load sustainability based on training hours, recovery time, and injury risk

### Technical Structure
The system consists of three main components:

1. **Machine Learning Models**: Linear regression models trained on athletic performance and injury data
   - Models are saved as serialized files (`model.pkl`) and loaded by the API

2. **Flask API Backend**: RESTful service that provides predictions
   - Endpoints:
     - `/predict-ars`: Predicts ACL Risk Score based on fatigue level
     - `/predict-load-balance-score`: Calculates training load balance using multiple variables

3. **Flutter Mobile Application**: User-friendly interface for athletes
   - Features:
     - Interactive sliders to input training variables
     - Visual representation of risk scores
     - Personalized feedback based on predictions

### Data Flow
1. User inputs their current fatigue level, training hours, and recovery days in the mobile app
2. App sends data to the API endpoints
3. API processes the data using the trained linear regression models
4. Prediction results are returned to the app and displayed visually
5. Users can adjust their training parameters to see how changes affect their injury risk

## Benefits
- **Evidence-based Training**: Replace guesswork with data-driven decisions
- **Injury Prevention**: Identify high-risk training patterns before they lead to injury
- **Performance Optimization**: Find the optimal balance between training intensity and recovery
- **Personalization**: Recommendations tailored to individual training patterns

## Future Enhancements
- Integration with wearable fitness devices for automated data collection
- Additional prediction models for different types of sports injuries
- Team management features for coaches to monitor multiple athletes
