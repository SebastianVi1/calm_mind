import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

/// Service class responsible for managing user data in Firebase
/// Handles saving and retrieving user information, including onboarding answers
class UserService {
  /// Firestore instance for database operations
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Firebase Auth instance for user authentication
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Saves or updates user data in Firestore
  /// Creates a new document if it doesn't exist, updates if it does
  /// @param user - The UserModel to save
  /// @throws Exception if saving fails
  Future<void> saveUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } catch (e) {
      throw Exception('Error al guardar los datos del usuario: ${e.toString()}');
    }
  }

  /// Gets user data from Firestore
  /// @param uid - The user's unique identifier
  /// @return UserModel if found, null otherwise
  /// @throws Exception if retrieval fails
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener los datos del usuario: ${e.toString()}');
    }
  }

  /// Saves question answers for the current user
  /// If user is authenticated, saves to their profile
  /// @param answers - List of answers to save
  /// @throws Exception if saving fails
  Future<void> saveQuestionAnswers(List<String> answers) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado');
      }

      final userData = await getUserData(user.uid);
      if (userData == null) {
        // If user document doesn't exist, create it
        final newUser = UserModel(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoURL: user.photoURL,
          questionAnswers: answers,
          hasCompletedQuestions: true,
        );
        await saveUserData(newUser);
      } else {
        await saveUserData(userData.copyWith(
          questionAnswers: answers,
          hasCompletedQuestions: true,
        ));
      }
    } catch (e) {
      throw Exception('Error al guardar las respuestas: ${e.toString()}');
    }
  }

  /// Creates an anonymous user and saves their answers
  /// Used when a user completes onboarding without authentication
  /// @param answers - List of answers to save
  /// @return The anonymous user's UID
  /// @throws Exception if creation fails
  Future<String> createAnonymousUser(List<String> answers) async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Error al crear usuario anónimo');
      }

      final userModel = UserModel(
        uid: user.uid,
        questionAnswers: answers,
        hasCompletedQuestions: true,
      );
      await saveUserData(userModel);
      return user.uid;
    } catch (e) {
      throw Exception('Error al crear usuario+ anónimo: ${e.toString()}');
    }
  }

  /// Checks if the current user has completed the questions
  /// @return true if user exists and has completed questions, false otherwise
  /// @throws Exception if check fails
  Future<bool> hasCompletedQuestions() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return false;
      }

      // Intentar hasta 2 veces obtener los datos del usuario desde Firestore
      UserModel? userData;
      for (int i = 0; i < 2; i++) {
        try {
          final doc = await _firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            userData = UserModel.fromMap(doc.data()!);
            break;
          }
          // Si no hay datos y no es el último intento, esperar antes de reintentar
          if (i < 1) await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          // Si hay error en la consulta, esperar antes de reintentar
          if (i < 1) await Future.delayed(const Duration(milliseconds: 300));
        }
      }
      
      // Si no hay datos después de los intentos, retornar false
      if (userData == null) {
        return false;
      }
      
      return userData.hasCompletedQuestions;
    } catch (e) {
      // Registrar el error para diagnóstico
      print('Error al verificar si completó las preguntas: ${e.toString()}');
      // Si hay un error, asumir que las preguntas no están completadas
      return false;
    }
  }
} 
