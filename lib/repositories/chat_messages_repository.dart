import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_mind/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class ChatMessagesRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _uuid = const Uuid();

  // Get the chats collection
  CollectionReference get _chatsCollection => _firestore.collection('chats');

  // Get the user's chat document reference
  DocumentReference get _userChatDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _chatsCollection.doc(userId);
  }

  // Save a new message to the user's chat document
  Future<void> saveMessage(ChatMessage message) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      // Get the user's chat document
      final chatDoc = await _userChatDoc.get();
      
      if (!chatDoc.exists) {
        // Create new chat document for the user
        await _userChatDoc.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'sessions': {
            message.sessionId: {
              'messages': [message.toMap()],
              'createdAt': FieldValue.serverTimestamp(),
              'lastUpdated': FieldValue.serverTimestamp(),
            }
          }
        });
      } else {
        // Update existing chat document
        final data = chatDoc.data() as Map<String, dynamic>;
        final sessions = Map<String, dynamic>.from(data['sessions'] ?? {});

        if (!sessions.containsKey(message.sessionId)) {
          // Create new session
          sessions[message.sessionId] = {
            'messages': [message.toMap()],
            'createdAt': FieldValue.serverTimestamp(),
            'lastUpdated': FieldValue.serverTimestamp(),
          };
        } else {
          // Add message to existing session
          final session = Map<String, dynamic>.from(sessions[message.sessionId]);
          final messages = List<Map<String, dynamic>>.from(session['messages'] ?? []);
          messages.add(message.toMap());
          session['messages'] = messages;
          session['lastUpdated'] = FieldValue.serverTimestamp();
          sessions[message.sessionId] = session;
        }

        await _userChatDoc.update({
          'sessions': sessions,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al guardar el mensaje: $e');
      throw Exception('Error al guardar el mensaje: $e');
    }
  }

  // Get all chat sessions for the current user
  Stream<List<ChatMessage>> getChatHistory() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      return _userChatDoc.snapshots().map((snapshot) {
        if (!snapshot.exists) return [];

        final data = snapshot.data() as Map<String, dynamic>;
        final sessions = Map<String, dynamic>.from(data['sessions'] ?? {});
        
        final messages = <ChatMessage>[];
        for (final session in sessions.values) {
          final sessionData = Map<String, dynamic>.from(session);
          final sessionMessages = List<Map<String, dynamic>>.from(sessionData['messages'] ?? []);
          messages.addAll(
            sessionMessages.map((msg) => ChatMessage.fromMap(msg))
          );
        }
        
        return messages;
      });
    } catch (e) {
      print('Error al obtener el historial: $e');
      return Stream.value([]);
    }
  }

  // Delete a specific session
  Future<void> deleteSession(String sessionId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final chatDoc = await _userChatDoc.get();
      if (!chatDoc.exists) return;

      final data = chatDoc.data() as Map<String, dynamic>;
      final sessions = Map<String, dynamic>.from(data['sessions'] ?? {});
      
      if (sessions.containsKey(sessionId)) {
        sessions.remove(sessionId);
        await _userChatDoc.update({
          'sessions': sessions,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error al eliminar la sesión: $e');
      throw Exception('Error al eliminar la sesión: $e');
    }
  }

  // Clear all sessions for the current user
  Future<void> clearAllSessions() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      await _userChatDoc.update({
        'sessions': {},
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error al limpiar las sesiones: $e');
      throw Exception('Error al limpiar las sesiones: $e');
    }
  }
}
