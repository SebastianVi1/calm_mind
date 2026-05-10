import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';
import 'package:calm_mind/services/ai/i_ai_service.dart';

/// Service that handles communication with the Google Gemini AI API
/// Provides virtual therapy functionality through AI chat with personalized mental health assessment
class GeminiService implements IAIService {
  final String _apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  UserModel? _currentUser;
  final QuestionViewModel _questionViewModel;
  
  GeminiService()
      : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '',
        _questionViewModel = QuestionViewModel() {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env file');
    }
    _initializeModel();
    _initializeUser();
  }

  void _initializeUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromFirebase(user);
      }
    } catch (e) {
      print('Error initializing user in GeminiService: $e');
    }
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_defaultSystemMessage),
    );
    _chat = _model.startChat();
  }

  /// Generates the system message for the AI including:
  /// - User context and mental health evaluation
  /// - Personalized treatment instructions
  /// - General behavior guidelines
  /// - Emergency resources
  String get _defaultSystemMessage {
    return '''
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
  }

  String _buildDetailedEvaluation() {
    final answers = _currentUser?.questionAnswers ?? [];
    int depressionScore = 0;
    int anxietyScore = 0;
    int socialScore = 0;
    bool hasSuicidalThoughts = false;

    if (answers.isNotEmpty) {
      if (answers[0] == 'Sí') depressionScore += 2;
      if (answers[2] == 'Sí') depressionScore += 2;
      if (answers[5] == 'Sí') depressionScore += 1;
      if (answers[8] == 'Sí') depressionScore += 2;
    }

    if (answers.length > 1) {
      if (answers[1] == 'Sí') anxietyScore += 2;
      if (answers[3] == 'Sí') anxietyScore += 2;
      if (answers[4] == 'Sí') anxietyScore += 2;
      if (answers[6] == 'Sí') anxietyScore += 1;
    }

    if (answers.length > 6) {
      if (answers[6] == 'Sí') socialScore += 2;
    }

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

  String _buildTreatmentInstructions() {
    final answers = _currentUser?.questionAnswers ?? [];
    final instructions = <String>[];

    if (answers.isNotEmpty && answers[0] == 'Sí') {
      instructions.add('1. Focus on validating feelings of sadness and offering emotional regulation techniques');
    }
    if (answers.length > 1 && answers[1] == 'Sí') {
      instructions.add('2. Prioritize anxiety management and mindfulness techniques');
    }
    if (answers.length > 6 && answers[6] == 'Sí') {
      instructions.add('3. Offer gradual strategies for handling social situations');
    }
    if (answers.length > 9 && answers[9] == 'Sí') {
      instructions.add('4. PRIORITY: Assess suicide risk in each interaction and refer to emergency services if needed');
    }
    instructions.add('5. Maintain a proactive and solution-oriented approach');
    instructions.add('6. Offer specific resources and tools based on identified needs');
    instructions.add('7. Establish clear boundaries about the scope of virtual therapy');

    return instructions.join('\n');
  }

  String _buildQuestionAnswers() {
    final answers = <String>[];
    for (var i = 0; i < _questionViewModel.questions.length; i++) {
      answers.add('${_questionViewModel.questions[i].question}: ${_currentUser?.questionAnswers?[i] ?? 'Not specified'}');
    }
    return answers.join('\n  ');
  }

  @override
  Future<String> sendMessage(String message) async {
    try {
      final content = await _chat.sendMessage(Content.text(message));
      return content.text ?? 'Lo siento, no pude generar una respuesta.';
    } catch (e) {
      throw Exception('Error sending message to Gemini: $e');
    }
  }

  @override
  Stream<String> sendMessageStream(String message) async* {
    try {
      final responses = _chat.sendMessageStream(Content.text(message));
      await for (final chunk in responses) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e, stackTrace) {
      print('Gemini Streaming Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Streaming error from Gemini: $e');
    }
  }

  @override
  void clearHistory() {
    _chat = _model.startChat();
  }

  @override
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 2000,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: maxTokens,
        ),
      );
      final response = await model.generateContent([Content.text(userPrompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Error generating content with Gemini: $e');
    }
  }
}
