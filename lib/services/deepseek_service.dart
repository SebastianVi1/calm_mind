import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';
import 'dart:async';

/// Service that handles communication with the DeepSeek AI API
/// This service provides a virtual therapist functionality through AI chat
class DeepSeekService {
  late final UserModel _currentUser;
  final QuestionViewModel _questionViewModel = QuestionViewModel();
  static const String _baseUrl = 'https://api.deepseek.com';
  late final String _apiKey;
  bool _isInitialized = false;
  String? _lastSystemMessage;

  /// Constructor that initializes the service with:
  /// - API key from environment variables
  /// - Current Firebase user
  /// - Initializes the context for the AI chat
  DeepSeekService() {
    _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('DeepSeek API key not found in .env file');
    }
    User user = FirebaseAuth.instance.currentUser!;
    _currentUser = UserModel(uid: user.uid);
    _initializeContext();
  }

  /// Initializes the chat context with the AI
  /// This is called once when the service is created
  Future<void> _initializeContext() async {
    if (!_isInitialized) {
      try {
        _lastSystemMessage = _defaultSystemMessage;
        await _sendInitialContext();
        _isInitialized = true;
      } catch (e) {
        print('Error initializing context: $e');
      }
    }
  }

  /// Sends the initial context to the AI
  /// This includes the system message and a welcome message
  Future<void> _sendInitialContext() async {
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': _lastSystemMessage},
          {'role': 'assistant', 'content': 'Hola, soy Albert, tu terapeuta virtual. Estoy aquí para ayudarte con tu bienestar emocional. ¿Cómo te sientes hoy?'}
        ],
        'stream': false,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to initialize context: ${response.body}');
    }
  }

  /// Generates the default system message for the AI
  /// This message includes:
  /// - User context (ID, name, questionnaire answers)
  /// - Instructions for the AI's behavior
  /// - Emergency resources
  String get _defaultSystemMessage => '''
Eres un terapeuta virtual especializado en salud mental y bienestar emocional. 
Tu objetivo es ayudar a las personas a manejar sus emociones, reducir el estrés y mejorar su bienestar mental.
Ante el primer mensaje del usuario, tienes que presentarte como Albert y saludarle por su nombre.
Contexto del usuario:
- ID: ${_currentUser.uid}
- Nombre: ${_currentUser.displayName ?? 'No especificado'}
- Algunas cosas des usuario son:
   - Pregunta: ${_questionViewModel.questions[0].question }
   - Respuesta: ${_currentUser.questionAnswers?[0] ?? 'No especificado'}
   - Pregunta: ${_questionViewModel.questions[1].question}
   - Respuesta: ${_currentUser.questionAnswers?[1] ?? 'No especificado'}
   - Pregunta: ${_questionViewModel.questions[2].question}
   - Respuesta: ${_currentUser.questionAnswers?[2] ?? 'No especificado'}

Instrucciones específicas:
1. Mantén un tono empático, profesional y cálido en todo momento.
2. Siempre responde en español y adapta tu lenguaje al nivel de comprensión del usuario.
3. Si el usuario expresa sentimientos de crisis o emergencia, recomienda buscar ayuda profesional inmediata.
4. Pregunta por el estado emocional del usuario si no lo menciona.
5. Sugiere técnicas de respiración o mindfulness cuando sea apropiado.
6. Evita dar diagnósticos médicos o psicológicos.
7. Si el usuario menciona pensamientos suicidas, proporciona inmediatamente números de emergencia y recursos de ayuda.
8. Mantén la confidencialidad y no compartas información personal del usuario.
9. Si el usuario menciona problemas específicos, sugiere ejercicios prácticos para manejarlos.
10. Recuerda que eres un complemento a la terapia profesional, no un reemplazo.

Recursos de emergencia:
- Línea de prevención del suicidio: 911
- Centro de atención psicológica: 800-911-2000
- Emergencias: 911

Recuerda que tu objetivo principal es proporcionar apoyo emocional y herramientas prácticas para el manejo del estrés y las emociones.
''';

  /// Sends a message to the AI and gets a response
  /// [message] - The user's message to send
  /// [systemMessage] - Optional custom system message to override the default one
  /// Returns a Stream of the AI's response as it is being generated
  Stream<String> sendMessageStream(String message, {String? systemMessage}) async* {
    if (!_isInitialized) {
      await _initializeContext();
    }

    final request = http.Request('POST', Uri.parse('$_baseUrl/chat/completions'));
    request.headers.addAll({
      'Content-Type': 'application/json; charset=utf-8',
      'Authorization': 'Bearer $_apiKey',
    });

    // Use cached system message if no new one is provided
    final effectiveSystemMessage = systemMessage ?? _lastSystemMessage ?? _defaultSystemMessage;
    _lastSystemMessage = effectiveSystemMessage;

    request.body = jsonEncode({
      'model': 'deepseek-chat',
      'messages': [
        {'role': 'system', 'content': effectiveSystemMessage},
        {'role': 'user', 'content': message}
      ],
      'stream': true,
      'temperature': 0.7, // Add temperature for more consistent responses
      'max_tokens': 500, // Limit response length
    });

    final response = await http.Client().send(request);
    
    if (response.statusCode != 200) {
      throw Exception('Failed to get response from DeepSeek API: ${await response.stream.bytesToString()}');
    }

    String buffer = '';
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      buffer += chunk;
      final lines = buffer.split('\n');
      buffer = lines.removeLast(); // Keep the last incomplete line in the buffer

      for (final line in lines) {
        if (line.startsWith('data: ')) {
          final data = line.substring(6);
          if (data == '[DONE]') break;
          
          try {
            final json = jsonDecode(data);
            final content = json['choices'][0]['delta']['content'] ?? '';
            if (content.isNotEmpty) {
              yield content;
            }
          } catch (e) {
            // Skip invalid JSON
            continue;
          }
        }
      }
    }
  }

  /// Sends a message to the DeepSeek API and returns the response
  /// [message] - The user's message to send
  /// [systemMessage] - Optional system message to override the default context
  /// Returns the AI's response as a string
  Future<String> sendMessage(String message, {String? systemMessage}) async {
    // Initialize context if not already done
    if (!_isInitialized) {
      await _initializeContext();
    }

    // Use provided system message, last used message, or default message
    final effectiveSystemMessage = systemMessage ?? _lastSystemMessage ?? _defaultSystemMessage;
    _lastSystemMessage = effectiveSystemMessage;

    // Make HTTP POST request to DeepSeek API
    final response = await http.post(
      Uri.parse('$_baseUrl/chat/completions'),
      headers: {
        'Content-Type': 'application/json; charset=utf-8',
        'Authorization': 'Bearer $_apiKey',
      },
      body: jsonEncode({
        'model': 'deepseek-chat',
        'messages': [
          {'role': 'system', 'content': effectiveSystemMessage},
          {'role': 'user', 'content': message}
        ],
        'stream': false,
        'temperature': 0.7,
        'max_tokens': 500,
      }),
    );

    // Process successful response
    if (response.statusCode == 200) {
      final data = jsonDecode(utf8.decode(response.bodyBytes));
      return data['choices'][0]['message']['content'];
    } else {
      throw Exception('Failed to get response from DeepSeek API: ${response.body}');
    }
  }

} 
