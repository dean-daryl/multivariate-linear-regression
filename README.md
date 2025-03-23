# Athlete Injury Prediction System

## Mission
My mission is to reduce sports-related injuries by using machine learning to predict injury risk and optimize training routines. This system helps athletes and coaches make informed decisions about training intensity and recovery, leading to better performance outcomes while minimizing injury potential.

## Demo
Athlete Injury Prediction Demo

Watch [2-minute demo on YouTube]

```
https://www.loom.com/share/8de6078dd8f24e33b8b8a880a7f54da1?sid=b32ea569-f77d-4892-beb4-35541c5c2e26
```
## Public API Endpoint
The API is deployed and publicly available at:
```
https://multivariate-linear-regression-9eoa.onrender.com
```

### API Documentation (Swagger UI)
The API is documented using Swagger UI, which provides an interactive way to test the endpoints:

```
https://multivariate-linear-regression-9eoa.onrender.com/docs
```

#### Available Endpoints:
- **Predict ACL Risk Score**: `POST /predict-ars`
  - Input: `{"fatigue_score": 5.0}`
  - Output: `{"ACL Risk Score": 16.6}`

- **Predict Load Balance Score**: `POST /predict-load-balance-score`
  - Input: `{"training_hours_per_week": 7.0, "recovery_days_per_week": 2, "acl_risk_score": 16.6}`
  - Output: `{"Load Balance Score": 72.5}`

## How It Works

### Overview
The Athlete Injury Prediction System uses machine learning to analyze training patterns and provide personalized risk assessments. The system evaluates two key metrics:

1. **ACL Injury Risk Score**: Calculates the probability of ACL injury based on fatigue levels
2. **Load Balance Score**: Evaluates overall training load sustainability based on training hours, recovery time, and injury risk

### Technical Structure
The system consists of three main components:

1. **Machine Learning Models**: Linear regression models trained on athletic performance and injury data
   - Models are saved as serialized files (`model.pkl`) and loaded by the API

2. **FastAPI Backend**: RESTful service that provides predictions
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

## Installation and Setup

### Prerequisites
- Python 3.7+ for the API server
- Flutter SDK 3.0+ for the mobile application
- pip (Python package manager)
- Android Studio or Xcode for mobile development

### API Setup
1. Clone the repository
   ```
   git clone https://github.com/dean-daryl/multivariate-linear-regression.git
   cd athlete-injury-prediction/API
   ```

2. Install required Python packages
   ```
   pip install -r requirements.txt
   ```

3. Start the server with uvicorn
   ```
   uvicorn app:app --host 0.0.0.0 --port 8000
   ```
   The API will be available at http://localhost:8000

### Flutter App Setup
1. Navigate to the Flutter project directory
   ```
   cd ../FluttterApp/injuryprediction
   ```

2. Get Flutter dependencies
   ```
   flutter pub get
   ```

3. Run the app in development mode
   ```
   flutter run
   ```
   
   - If using an emulator:
     - Ensure Android/iOS emulator is running
     - The app will connect to the API at `http://10.0.2.2:8000` (Android) or `http://localhost:8000` (iOS)
   
   - If using a physical device:
     - Connect your device via USB and enable USB debugging
     - Modify API URLs in the app to use the public endpoint (see below)

4. To build a release version
   ```
   flutter build apk  # For Android
   flutter build ios  # For iOS
   ```

### Using the Public API
To use the deployed API instead of running locally:
1. Update the API URLs in the Flutter app (in lib/main.dart):
   ```dart
   // From
   Uri.parse('http://10.0.2.2:8000/predict-ars')
   // To
   Uri.parse('https://multivariate-linear-regression-9eoa.onrender.com/predict-ars')
   
   // And from
   Uri.parse('http://10.0.2.2:8000/predict-load-balance-score')
   // To
   Uri.parse('https://multivariate-linear-regression-9eoa.onrender.com/predict-load-balance-score')
   ```

## Troubleshooting
- If experiencing rendering issues on iOS/Android, try:
  - Disabling hardware acceleration in Android
  - Using a device with better GPU support
  - Reducing visual effects in the UI

## Benefits
- **Evidence-based Training**: Replace guesswork with data-driven decisions
- **Injury Prevention**: Identify high-risk training patterns before they lead to injury
- **Performance Optimization**: Find the optimal balance between training intensity and recovery
- **Personalization**: Recommendations tailored to individual training patterns

## Future Enhancements
- Integration with wearable fitness devices for automated data collection
- Additional prediction models for different types of sports injuries
- Team management features for coaches to monitor multiple athletes
