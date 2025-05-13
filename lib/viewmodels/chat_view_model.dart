import 'package:flutter/foundation.dart';

import 'package:calm_mind/models/chat_message.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:uuid/uuid.dart';
import '../services/deepseek_service.dart';
import '../repositories/chat_messages_repository.dart';
import 'dart:async';

/// ViewModel for managing chat functionality
/// Handles message sending, receiving, and UI state
class ChatViewModel extends ChangeNotifier {
  // Service for AI communication
  final DeepSeekService _deepSeekService;
  // Repository for chat persistence
  final ChatMessagesRepository _chatRepository = ChatMessagesRepository();
  
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

  // Current session ID
  String _currentSessionId = '';

  // Track if the session has any messages
  bool _hasMessages = false;

  // Stream subscription for chat history
  StreamSubscription? _chatHistorySubscription;

  final Map<String, List<ChatMessage>> _sessions = {};
  Map<String, List<ChatMessage>> get sessions => _sessions;

  ChatViewModel(this._deepSeekService) {
    // Start a new session when the app starts
    startNewSession();
    // Load chat history for the history page
    _loadChatHistory();
  }

  /// Loads chat history from Firestore
  Future<void> _loadChatHistory() async {
    try {
      _chatHistorySubscription?.cancel();
      _chatHistorySubscription = _chatRepository.getChatHistory().listen(
        (messages) {
          // Group messages by session
          _sessions.clear();
          for (final message in messages) {
            _sessions.putIfAbsent(message.sessionId, () => []).add(message);
          }

          // Sort messages within each session
          for (final session in _sessions.values) {
            session.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          }

          notifyListeners();
        },
        onError: (error) {
          print('Error loading chat history: $error');
        },
      );
    } catch (e) {
      print('Error setting up chat history subscription: $e');
    }
  }

  /// Starts a new chat session
  Future<void> startNewSession() async {
    try {
      _currentSessionId = _uuid.v4();
      _messages.clear();
      _hasSentContext = false;
      _hasMessages = false;
      _currentResponse = '';
      _stopTypingAnimation();
      
      // Add welcome message but don't save it yet
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Hola, soy Albert ☺️. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    } catch (e) {
      print('Error starting new session: $e');
    }
  }

  /// Continues with an existing session
  Future<void> continueSession(String sessionId) async {
    try {
      _currentSessionId = sessionId;
      _messages.clear();
      _hasSentContext = false;
      _currentResponse = '';
      _stopTypingAnimation();
      
      final sessionMessages = _sessions[sessionId];
      if (sessionMessages != null && sessionMessages.isNotEmpty) {
        _messages.addAll(sessionMessages);
        _hasMessages = true;
        notifyListeners();
      }
    } catch (e) {
      print('Error continuing session: $e');
    }
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
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
      sessionId: _currentSessionId,
    );
    _messages.add(userMessage);
    
    // Save messages only if this is the first message in the session
    if (!_hasMessages) {
      _hasMessages = true;
      // Save the welcome message and user message
      await _chatRepository.saveMessage(_messages.first);
      await _chatRepository.saveMessage(userMessage);
    } else {
      // Just save the new message
      await _chatRepository.saveMessage(userMessage);
    }
    
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
      sessionId: _currentSessionId,
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
        final updatedAiMessage = ChatMessage(
          id: aiMessage.id,
          content: _currentResponse,
          isUser: false,
          timestamp: DateTime.now(),
          sessionId: _currentSessionId,
        );
        _messages.add(updatedAiMessage);
        notifyListeners();
      }

      // Save the complete AI message only after streaming is done
      await _chatRepository.saveMessage(_messages.last);

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
      final errorMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Lo siento, hubo un error al procesar tu mensaje. Por favor, intenta de nuevo.',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
      );
      _messages.add(errorMessage);
      // Save error message to Firestore
      await _chatRepository.saveMessage(errorMessage);
      notifyListeners();
    }
  }

  /// Clears the chat history and resets to initial state
  Future<void> clearChat() async {
    try {
      // Only delete sessions if they have messages
      if (_hasMessages) {
        await _chatRepository.clearAllSessions();
      }
      
      _messages.clear();
      _stopTypingAnimation();
      _currentResponse = '';
      _isLoading = false;
      _hasSentContext = false;
      _hasMessages = false;
      
      // Create new session
      _currentSessionId = _uuid.v4();
      
      // Add welcome message back but don't save it yet
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Hola, soy Albert ☺️. ¿En qué puedo ayudarte hoy?',
        isUser: false,
        timestamp: DateTime.now(),
        sessionId: _currentSessionId,
      );
      _messages.add(welcomeMessage);
      notifyListeners();
    } catch (e) {
      print('Error clearing chat: $e');
    }
  }

  @override
  void dispose() {
    _typingAnimationTimer?.cancel();
    _chatHistorySubscription?.cancel();
    super.dispose();
  }
} 
