import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';

/// Service that handles communication with the DeepSeek AI API
/// Provides virtual therapy functionality through AI chat with personalized mental health assessment
class DeepSeekService {
  static const String _baseUrl = 'https://api.deepseek.com';
  final String _apiKey;
  UserModel? _currentUser;
  final QuestionViewModel _questionViewModel;
  String? _lastSystemMessage;
  final List<Map<String, String>> _conversationHistory = [];
  static const int _maxHistoryLength = 10;
  

  /// Constructor initializes the service with:
  /// - API key from environment variables
  /// - Current Firebase user
  /// - Question view model for mental health assessment
  DeepSeekService()
      : _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '',
        _questionViewModel = QuestionViewModel() {
    if (_apiKey.isEmpty) {
      throw Exception('DeepSeek API key not found in .env file');
    }
    _initializeUser();
  }

  void _initializeUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromFirebase(user);
      }
    } catch (e) {
      print('Error initializing user in DeepSeekService: $e');
    }
  }

  /// Generates the system message for the AI including:
  /// - User context and mental health evaluation
  /// - Personalized treatment instructions
  /// - General behavior guidelines
  /// - Emergency resources
  String get _defaultSystemMessage => '''
You are Numa, a virtual therapist specialized in mental health.

User Context:
Name: ${_currentUser?.displayName ?? 'Not specified'}

User Evaluation:
${_buildDetailedEvaluation()}

Evaluation-based Instructions:
${_buildTreatmentInstructions()}

General Instructions:
1. Maintain an empathetic and professional tone, adapted to the detected severity level
2. Respond in Spanish in a natural and conversational manner
3. Avoid using asterisks or special characters in responses
4. Use emojis moderately and appropriately to the emotional context
5. Be concise and direct in responses
6. Suggest breathing and mindfulness techniques when appropriate
7. In case of crisis or concerning responses, prioritize safety and recommend professional help
8. Provide practical exercises adapted to the user's profile
9. Maintain a positive but realistic approach
10. Validate user's feelings and normalize their experiences
11. Offer specific resources and tools based on identified needs
12. Establish clear boundaries about the scope of virtual therapy

Emergency Resources:
- Suicide Prevention Line: 911
- Psychological Support Center: 800-911-2000
- Crisis Intervention Unit: 800-227-4747
- Life Line: 800-911-2000

Remember: If suicide risk or severe crisis is detected, prioritize referral to emergency services.
''';

  /// Builds a detailed mental health evaluation based on questionnaire answers
  /// Calculates scores for depression, anxiety, and social aspects
  /// Determines overall severity level and suicide risk
  String _buildDetailedEvaluation() {
    final answers = _currentUser?.questionAnswers ?? [];
    int depressionScore = 0;
    int anxietyScore = 0;
    int socialScore = 0;
    bool hasSuicidalThoughts = false;

    // Depression assessment
    if (answers.isNotEmpty) {
      if (answers[0] == 'Sí') depressionScore += 2; // Sadness
      if (answers[2] == 'Sí') depressionScore += 2; // Loss of interest
      if (answers[5] == 'Sí') depressionScore += 1; // Fatigue
      if (answers[8] == 'Sí') depressionScore += 2; // Lack of motivation
    }

    // Anxiety assessment
    if (answers.length > 1) {
      if (answers[1] == 'Sí') anxietyScore += 2; // Excessive worry
      if (answers[3] == 'Sí') anxietyScore += 2; // Difficulty relaxing
      if (answers[4] == 'Sí') anxietyScore += 2; // Sleep problems
      if (answers[6] == 'Sí') anxietyScore += 1; // Social avoidance
    }

    // Social assessment
    if (answers.length > 6) {
      if (answers[6] == 'Sí') socialScore += 2; // Social avoidance
    }

    // Risk assessment
    if (answers.length > 9) {
      hasSuicidalThoughts = answers[9] == 'Sí';
    }

    String severity = 'Mild';
    if (depressionScore + anxietyScore >= 8) {
      severity = 'Severe';
    } else if (depressionScore + anxietyScore >= 5) {
      severity = 'Moderate';
    }

    return '''
Severity Level: $severity
Depression Score: $depressionScore/7
Anxiety Score: $anxietyScore/7
Social Score: $socialScore/2
Suicide Risk: ${hasSuicidalThoughts ? 'HIGH - Requires immediate attention' : 'Low'}

Detailed Responses:
${_buildQuestionAnswers()}
''';
  }

  /// Generates personalized treatment instructions based on user's answers
  /// Prioritizes different approaches based on detected issues
  String _buildTreatmentInstructions() {
    final answers = _currentUser?.questionAnswers ?? [];
    final instructions = <String>[];

    // Depression-based instructions
    if (answers.isNotEmpty && answers[0] == 'Sí') {
      instructions.add('1. Focus on validating feelings of sadness and offering emotional regulation techniques');
    }

    // Anxiety-based instructions
    if (answers.length > 1 && answers[1] == 'Sí') {
      instructions.add('2. Prioritize anxiety management and mindfulness techniques');
    }

    // Social issues-based instructions
    if (answers.length > 6 && answers[6] == 'Sí') {
      instructions.add('3. Offer gradual strategies for handling social situations');
    }

    // Suicide risk-based instructions
    if (answers.length > 9 && answers[9] == 'Sí') {
      instructions.add('4. PRIORITY: Assess suicide risk in each interaction and refer to emergency services if needed');
    }

    // General instructions
    instructions.add('5. Maintain a proactive and solution-oriented approach');
    instructions.add('6. Offer specific resources and tools based on identified needs');
    instructions.add('7. Establish clear boundaries about the scope of virtual therapy');

    return instructions.join('\n');
  }

  /// Builds a formatted string of question answers for the AI context
  String _buildQuestionAnswers() {
    final answers = <String>[];
    for (var i = 0; i < _questionViewModel.questions.length; i++) {
      if (i < _questionViewModel.questions.length) {
        answers.add('${_questionViewModel.questions[i].question}: ${_currentUser?.questionAnswers?[i] ?? 'Not specified'}');
      }
    }
    return answers.join('\n  ');
  }

  /// Returns the formatted messages array for the API request
  /// Includes system message and conversation history
  List<Map<String, String>> get _messages {
    return [
      {'role': 'system', 'content': _lastSystemMessage ?? _defaultSystemMessage},
      ..._conversationHistory,
    ];
  }

  /// Adds a message to the conversation history
  /// Maintains a maximum history length by removing oldest messages
  void _addToHistory(String role, String content) {
    _conversationHistory.add({'role': role, 'content': content});
    if (_conversationHistory.length > _maxHistoryLength * 2) {
      _conversationHistory.removeRange(0, 2);
    }
  }

  /// Sends a message to the DeepSeek API and returns the response
  /// [message] - The user's message to send
  /// Returns the AI's response as a string
  Future<String> sendMessage(String message) async {
    try {
      _addToHistory('user', message);

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': _messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final assistantMessage = data['choices'][0]['message']['content'];
        _addToHistory('assistant', assistantMessage);
        return assistantMessage;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }

  /// Sends a message to the AI and gets a response
  /// [message] - The user's message to send
  /// Returns a Stream of the AI's response as it is being generated
  Stream<String> sendMessageStream(String message) async* {
    try {
      _addToHistory('user', message);

      final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
      request.headers.addAll({
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_apiKey',
      });

      request.body = jsonEncode({
        'model': 'deepseek-chat',
        'messages': _messages,
        'stream': true,
        'temperature': 0.7,
        'max_tokens': 500,
      });

      final response = await http.Client().send(request);
      
      if (response.statusCode != 200) {
        throw Exception('API Error: ${response.statusCode}');
      }

      String buffer = '';
      String fullResponse = '';
      
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        buffer += chunk;
        final lines = buffer.split('\n');
        buffer = lines.removeLast();

        for (final line in lines) {
          if (line.startsWith('data: ')) {
            final data = line.substring(6);
            if (data == '[DONE]') break;
            
            try {
              final json = jsonDecode(data);
              final content = json['choices'][0]['delta']['content'] ?? '';
              if (content.isNotEmpty) {
                fullResponse += content;
                yield content;
              }
            } catch (e) {
              continue;
            }
          }
        }
      }
      
      _addToHistory('assistant', fullResponse);
    } catch (e) {
      throw Exception('Streaming Error: $e');
    }
  }

  /// Clears the conversation history
  void clearHistory() {
    _conversationHistory.clear();
  }
} 
