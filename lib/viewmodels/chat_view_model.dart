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

  // Current session ID
  String _currentSessionId = '';

  // Track if the session has any messages
  bool _hasMessages = false;

  // Stream subscription for chat history
  StreamSubscription? _chatHistorySubscription;

  final Map<String, List<ChatMessage>> _sessions = {};
  Map<String, List<ChatMessage>> get sessions => _sessions;

  ChatViewModel(this._deepSeekService) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // Start a new session when the app starts
      await startNewSession();
      // Load chat history for the history page
      await loadChatHistory();
    } catch (e) {
      print('Error initializing ChatViewModel: $e');
    }
  }

  /// Loads chat history from Firestore
  Future<void> loadChatHistory() async {
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

          // Sort sessions by most recent first
          final sortedSessions = Map.fromEntries(
            _sessions.entries.toList()
              ..sort((a, b) {
                final aLastMessage = a.value.last.timestamp;
                final bLastMessage = b.value.last.timestamp;
                return bLastMessage.compareTo(aLastMessage); // Reverse order
              })
          );
          _sessions.clear();
          _sessions.addAll(sortedSessions);

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
      _hasMessages = false;
      _currentResponse = '';
      _stopTypingAnimation();
      
      // Add welcome message but don't save it yet
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Hola, soy Numa☺️. ¿En qué puedo ayudarte hoy?',
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
      _hasMessages = false;
      
      // Create new session
      _currentSessionId = _uuid.v4();
      
      // Add welcome message back but don't save it yet
      final welcomeMessage = ChatMessage(
        id: _uuid.v4(),
        content: 'Hola, soy Numa ☺️. ¿En qué puedo ayudarte hoy?',
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
