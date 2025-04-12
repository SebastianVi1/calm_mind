import 'package:firebase_auth/firebase_auth.dart';
import 'package:re_mind/services/auth/i_auth_service.dart';

import '../../models/user_model.dart';

/// Implementation of IAuthService using Firebase Authentication
/// Handles all authentication operations with Firebase
class FirebaseAuthService implements IAuthService {
  /// Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Stream of authentication state changes
  /// Converts Firebase User to our UserModel
  @override
  Stream<UserModel?> get authStateChanges {
    return _auth.authStateChanges().map((user) {
      return user != null ? UserModel.fromFirebase(user) : null;
    });
  }

  /// Signs in a user with email and password
  /// Returns UserModel if successful, null otherwise
  @override
  Future<UserModel?> signInWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null ? UserModel.fromFirebase(result.user!) : null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  /// Creates a new user with email and password
  /// Returns UserModel if successful, null otherwise
  @override
  Future<UserModel?> createUserWithEmailAndPassword(
    String email, 
    String password,
  ) async {
    try {
      final result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user != null ? UserModel.fromFirebase(result.user!) : null;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthError(e);
    }
  }

  /// Signs out the current user
  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Handles Firebase authentication errors
  /// Converts Firebase error codes to user-friendly messages
  String _handleFirebaseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontro un usuario con este email.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'email-already-in-use':
        return 'El email ya esta en uso.';
      case 'weak-password':
        return 'La contraseña es demasiado debil.';
      case 'invalid-email':
        return 'El email es invalido.';
      default:
        return e.message ?? 'Ocurrio un error.';
    }
  }
} 