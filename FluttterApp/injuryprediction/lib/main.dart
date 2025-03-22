import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:ui'; // Add import for ImageFilter
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Injury Prediction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const InjuryPredictionPage(title: 'Fitness Tracker'),
    );
  }
}

class InjuryPredictionPage extends StatefulWidget {
  const InjuryPredictionPage({super.key, required this.title});

  final String title;

  @override
  State<InjuryPredictionPage> createState() => _InjuryPredictionPageState();
}

class _InjuryPredictionPageState extends State<InjuryPredictionPage> {
  double trainingHours = 7.0;
  int recoveryDays = 0;
  double aclRiskScore = 16.6;
  double loadBalanceScore = 0;
  double fatigueScore = 5.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Predict ACL Risk Score based on initial fatigue
    _predictACLRiskScore();
  }

  Future<void> _predictACLRiskScore() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      print('Sending ARS prediction request with fatigue score: $fatigueScore');
      
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict-ars'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fatigue_score': fatigueScore,
        }),
      );
      
      print('ARS Response: $response');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('ARS Response data: $data');
        
        setState(() {
          aclRiskScore = data['ACL Risk Score'];
          isLoading = false;
        });
        
        // Now that we have the ACL Risk Score, calculate the load balance
        _predictLoadBalance();
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to get ARS prediction: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception in ARS prediction: $e');
    }
  }

  Future<void> _predictLoadBalance() async {
    setState(() {
      isLoading = true;
    });
    
    try {
      print('Sending prediction request with values: Training Hours=$trainingHours, Recovery Days=$recoveryDays, ACL Risk Score=$aclRiskScore');
      
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/predict-load-balance-score'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'training_hours_per_week': trainingHours,
          'recovery_days_per_week': recoveryDays,
          'acl_risk_score': aclRiskScore,
        }),
      );

      print('Response: $response');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Response: ${response.body}, Data: $data');
        
        // Ensure we're updating the UI correctly and cap score at 100
        setState(() {
          loadBalanceScore = data['Load Balance Score'] > 100 ? 100 : data['Load Balance Score'];
          isLoading = false;
        });
      } else {
        // Handle error
        setState(() {
          isLoading = false;
        });
        print('Failed to get prediction: ${response.statusCode}, Body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Exception occurred: $e');
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 85) return Colors.green;
    if (score >= 75) return const Color(0xFFD4AF37); // Gold
    return Colors.redAccent;
  }

  String _getScoreCategory(double score) {
    if (score >= 85) return 'Excellent';
    if (score >= 75) return 'Moderate Risk';
    return 'High Risk';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Darker background
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E), // Darker app bar
        elevation: 0, // Remove shadow
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1A1A2E),
              const Color(0xFF0F3460),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Score Circle
              Expanded(
                flex: 3,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Load Balance Score',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer glow effect
                          Container(
                            width: 200,
                            height: 200,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: isLoading 
                                      ? Colors.blue.withOpacity(0.3) 
                                      : _getScoreColor(loadBalanceScore).withOpacity(0.3),
                                  blurRadius: 25,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                          ),
                          // Progress circle
                          SizedBox(
                            width: 180,
                            height: 180,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    strokeWidth: 15,
                                    backgroundColor: Color(0xFF16213E),
                                    color: Colors.blue,
                                  )
                                : CircularProgressIndicator(
                                    value: loadBalanceScore / 100,
                                    strokeWidth: 15,
                                    backgroundColor: const Color(0xFF16213E),
                                    color: _getScoreColor(loadBalanceScore),
                                  ),
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isLoading ? '' : '${loadBalanceScore.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontSize: 38,
                                  fontWeight: FontWeight.bold,
                                  color: isLoading ? Colors.white : _getScoreColor(loadBalanceScore),
                                  letterSpacing: 1.2,
                                ),
                              ),
                              AnimatedOpacity(
                                opacity: isLoading ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  isLoading ? 'Loading...' : _getScoreCategory(loadBalanceScore),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      // Display the calculated ACL Risk Score
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16213E).withOpacity(0.8),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                          border: Border.all(
                            color: Colors.redAccent.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.medical_information, color: Colors.redAccent, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'ACL Risk: ${aclRiskScore.toStringAsFixed(1)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Input Fields
              Expanded(
                flex: 4,
                child: Card(
                  color: const Color(0xFF16213E).withOpacity(0.7),
                  elevation: 20,
                  shadowColor: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: Colors.blueAccent.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.mood,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'How Are You Feeling Today?',
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Fatigue Score Slider with emoji indicators
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Fatigue Level',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.redAccent.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.redAccent.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '${fatigueScore.toStringAsFixed(1)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 6,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                          elevation: 4,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 20,
                                        ),
                                        activeTrackColor: Colors.redAccent,
                                        inactiveTrackColor: Colors.redAccent.withOpacity(0.2),
                                        thumbColor: Colors.redAccent,
                                        overlayColor: Colors.redAccent.withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value: fatigueScore,
                                        min: 1,
                                        max: 10,
                                        divisions: 18, // Allow for half points
                                        onChanged: (value) {
                                          setState(() {
                                            fatigueScore = value;
                                          });
                                        },
                                        onChangeEnd: (value) {
                                          // Re-calculate ACL Risk Score when fatigue changes
                                          _predictACLRiskScore();
                                        },
                                      ),
                                    ),
                                    // Emoji scale for the fatigue score
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            '😊',
                                            style: TextStyle(color: Colors.white70, fontSize: 20),
                                          ),
                                          const Text(
                                            '😐',
                                            style: TextStyle(color: Colors.white70, fontSize: 20),
                                          ),
                                          const Text(
                                            '😫',
                                            style: TextStyle(color: Colors.white70, fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Labels below emojis
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Fresh',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          const Text(
                                            'Normal',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                          const Text(
                                            'Exhausted',
                                            style: TextStyle(color: Colors.white70, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.fitness_center,
                                    color: Colors.white70,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'Training Variables',
                                    style: TextStyle(
                                      fontSize: 18, 
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              
                              // Training Hours Slider
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Training Hours/Week',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.blue.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '${trainingHours.toStringAsFixed(1)}h',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 6,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                          elevation: 4,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 20,
                                        ),
                                        activeTrackColor: Colors.blue,
                                        inactiveTrackColor: Colors.blue.withOpacity(0.2),
                                        thumbColor: Colors.blue,
                                        overlayColor: Colors.blue.withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value: trainingHours,
                                        min: 0,
                                        max: 40,
                                        divisions: 40,
                                        onChanged: (value) {
                                          setState(() {
                                            trainingHours = value;
                                          });
                                        },
                                        onChangeEnd: (value) {
                                          // Re-calculate when user stops dragging
                                          _predictLoadBalance();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Recovery Days Slider
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Recovery Days/Week',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.purple.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: Colors.purple.withOpacity(0.5),
                                              width: 1,
                                            ),
                                          ),
                                          child: Text(
                                            '$recoveryDays days',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    SliderTheme(
                                      data: SliderTheme.of(context).copyWith(
                                        trackHeight: 6,
                                        thumbShape: const RoundSliderThumbShape(
                                          enabledThumbRadius: 12,
                                          elevation: 4,
                                        ),
                                        overlayShape: const RoundSliderOverlayShape(
                                          overlayRadius: 20,
                                        ),
                                        activeTrackColor: Colors.purple,
                                        inactiveTrackColor: Colors.purple.withOpacity(0.2),
                                        thumbColor: Colors.purple,
                                        overlayColor: Colors.purple.withOpacity(0.2),
                                      ),
                                      child: Slider(
                                        value: recoveryDays.toDouble(),
                                        min: 0,
                                        max: 7,
                                        divisions: 7,
                                        onChanged: (value) {
                                          setState(() {
                                            recoveryDays = value.toInt();
                                          });
                                        },
                                        onChangeEnd: (value) {
                                          // Re-calculate when user stops dragging
                                          _predictLoadBalance();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            // First predict ACL Risk Score, which will then trigger Load Balance calculation
            _predictACLRiskScore();
          },
          tooltip: 'Predict',
          backgroundColor: const Color(0xFF0F3460),
          child: const Icon(
            Icons.refresh,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
