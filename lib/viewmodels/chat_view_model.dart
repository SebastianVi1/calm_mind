import 'package:flutter/foundation.dart';

import 'package:re_mind/models/chat_message.dart';
import 'package:re_mind/models/user_model.dart';
import 'package:uuid/uuid.dart';
import '../services/deepseek_service.dart';
import 'dart:async';

/// ViewModel for managing chat functionality
/// Handles message sending, receiving, and UI state
class ChatViewModel extends ChangeNotifier {
  // Service for AI communication
  final DeepSeekService _deepSeekService;
  
  // List of chat messages
  final List<ChatMessage> _messages = [];
  
  // UUID generator for message IDs
  final _uuid = const Uuid();
  
  // Loading state indicator
  bool _isLoading = false;
  
  // Current authenticated user
  UserModel? _currentUser;
  
  // Buffer for streaming AI responses
  String _currentResponse = '';
  
  // Timer for typing animation
  Timer? _typingAnimationTimer;
  
  // Current frame index for typing animation
  int _typingAnimationIndex = 0;
  
  // Animation frames for typing indicator
  final List<String> _typingAnimationFrames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];

  // Cache for user context to avoid sending it multiple times
  String? _cachedUserContext;
  bool _hasSentContext = false;


  ChatViewModel(this._deepSeekService) {
    // Initialize chat with welcome message
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: 'Hola, soy Albert ☺️. ¿En qué puedo ayudarte hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  /// Sets the current user and sends their context to the AI
  void setUser(UserModel user) {
    if (_currentUser?.uid != user.uid) {
      _currentUser = user;
      _hasSentContext = false;
      _sendUserContext();
    }
  }

  /// Sends the user's context to the AI without showing it in the chat
  Future<void> _sendUserContext() async {
    if (_currentUser == null || _hasSentContext) return;

    final context = '''
You are Albert, a concise virtual therapist. User context:
Name: ${_currentUser!.displayName ?? 'Not provided'}
Email: ${_currentUser!.email ?? 'Not provided'}
${_currentUser!.questionAnswers != null && _currentUser!.questionAnswers!.isNotEmpty 
  ? 'Previous answers: ${_currentUser!.questionAnswers!.join(" | ")}'
  : ''}

Guidelines:
- Be direct and concise
- Focus on practical advice
- Keep responses under 3 sentences
- Use simple language
- Stay solution-oriented
- Be empathetic but professional
- Avoid medical diagnoses
- Suggest professional help when needed
''';

    _cachedUserContext = context;

    try {
      await _deepSeekService.sendMessageStream('', systemMessage: context).drain();
      _hasSentContext = true;
    } catch (e) {
      print('Error sending context: $e');
      _hasSentContext = false;
    }
  }

  // Getters for public access to private fields
  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  UserModel? get currentUser => _currentUser;
  String get currentResponse => _currentResponse;
  String get typingAnimation => _typingAnimationFrames[_typingAnimationIndex];

  /// Starts the typing animation timer
  void _startTypingAnimation() {
    _typingAnimationTimer?.cancel();
    _typingAnimationTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _typingAnimationIndex = (_typingAnimationIndex + 1) % _typingAnimationFrames.length;
      notifyListeners();
    });
  }

  /// Stops the typing animation and resets the index
  void _stopTypingAnimation() {
    _typingAnimationTimer?.cancel();
    _typingAnimationTimer = null;
    _typingAnimationIndex = 0;
  }

  /// Sends a message to the AI and handles the response
  /// [message] - The user's message to send
  Future<void> sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    // Ensure context is sent before first message
    if (!_hasSentContext && _currentUser != null) {
      await _sendUserContext();
    }

    // Add user message to chat
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    // Set loading state and start typing animation
    _isLoading = true;
    _currentResponse = '';
    _startTypingAnimation();
    notifyListeners();
    
    // Create placeholder for AI response
    final aiMessage = ChatMessage(
      id: _uuid.v4(),
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
    );
    _messages.add(aiMessage);
    notifyListeners();

    try {
      // Stream AI response and update UI in real-time
      await for (final chunk in _deepSeekService.sendMessageStream(
        message,
        systemMessage: _cachedUserContext ?? 'Be concise and direct.',
      )) {
        _currentResponse += chunk;
        // Replace the last message with updated content
        _messages.removeLast();
        _messages.add(ChatMessage(
          id: _uuid.v4(),
          content: _currentResponse,
          isUser: false,
          timestamp: DateTime.now(),
        ));
        notifyListeners();
      }

      // Clean up after response is complete
      _stopTypingAnimation();
      _isLoading = false;
      _currentResponse = '';
      notifyListeners();
    } catch (e) {
      // Handle errors and show error message
      _stopTypingAnimation();
      _isLoading = false;
      _currentResponse = '';
      
      _messages.removeLast();
      _messages.add(ChatMessage(
        id: _uuid.v4(),
        content: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
      ));
      notifyListeners();
    }
  }

  /// Clears the chat history and resets to initial state
  void clearChat() {
    _messages.clear();
    _stopTypingAnimation();
    _currentResponse = '';
    _isLoading = false;
    _hasSentContext = false;
    
    // Add welcome message back
    _messages.add(ChatMessage(
      id: _uuid.v4(),
      content: 'Hola, soy Albert ☺️. ¿En qué puedo ayudarte hoy?',
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }

  @override
  void dispose() {
    _typingAnimationTimer?.cancel();
    super.dispose();
  }
} 