import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';

/// Service that handles communication with the DeepSeek AI API
/// This service provides a virtual therapist functionality through AI chat
class DeepSeekService {
  static const String _baseUrl = 'https://api.deepseek.com';
  final String _apiKey;
  final UserModel? _currentUser;
  final QuestionViewModel _questionViewModel;
  String? _lastSystemMessage;
  final List<Map<String, String>> _conversationHistory = [];
  static const int _maxHistoryLength = 10;
  

  /// Constructor that initializes the service with:
  /// - API key from environment variables
  /// - Current Firebase user
  /// - Initializes the context for the AI chat
  DeepSeekService()
      : 
        _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '',
        _currentUser = UserModel.fromFirebase(FirebaseAuth.instance.currentUser!),
        _questionViewModel = QuestionViewModel() {
    if (_apiKey.isEmpty) {
      throw Exception('DeepSeek API key not found in .env file');
    }
  }

  /// Generates the default system message for the AI
  /// This message includes:
  /// - User context (ID, name, questionnaire answers)
  /// - Instructions for the AI's behavior
  /// - Emergency resources
  String get _defaultSystemMessage => '''
Eres Numa, un terapeuta virtual especializado en salud mental.

Contexto del usuario:
Nombre: ${_currentUser?.displayName ?? 'No especificado'}

Respuestas del cuestionario:
${_buildQuestionAnswers()}

Instrucciones:
1. Mantén un tono empático y profesional
2. Responde en español de manera natural y conversacional
3. Evita usar asteriscos o caracteres especiales en tus respuestas
4. Usa emojis de manera moderada y apropiada
5. Sé conciso y directo en tus respuestas
6. Sugiere técnicas de respiración cuando sea apropiado
7. En caso de crisis, recomienda buscar ayuda profesional
8. Proporciona ejercicios prácticos cuando sea relevante
9. Dale un formato profesional y muy bonito con emojis

Recursos de emergencia:
- Línea de prevención del suicidio: 911
- Centro de atención psicológica: 800-911-2000
''';

  String _buildQuestionAnswers() {
    final answers = <String>[];
    for (var i = 0; i < 3; i++) {
      if (i < _questionViewModel.questions.length) {
        answers.add('${_questionViewModel.questions[i].question}: ${_currentUser?.questionAnswers?[i] ?? 'No especificado'}');
      }
    }
    return answers.join('\n  ');
  }

  List<Map<String, String>> get _messages {
    return [
      {'role': 'system', 'content': _lastSystemMessage ?? _defaultSystemMessage},
      ..._conversationHistory,
    ];
  }

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
        throw Exception('Error en la API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al enviar mensaje: $e');
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
        throw Exception('Error en la API: ${response.statusCode}');
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
      throw Exception('Error en el streaming: $e');
    }
  }

  void clearHistory() {
    _conversationHistory.clear();
  }
} 
