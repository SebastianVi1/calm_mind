import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_mind/services/auth/i_auth_service.dart';

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

  /// Gets the current user
  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    return user != null ? UserModel.fromFirebase(user) : null;
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
        return 'No existe una cuenta con este correo electrónico. Por favor, regístrate primero.';
      case 'wrong-password':
        return 'La contraseña es incorrecta. Por favor, verifica tu contraseña.';
      case 'email-already-in-use':
        return 'Este correo electrónico ya está registrado. Por favor, inicia sesión o usa otro correo.';
      case 'weak-password':
        return 'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo electrónico no es válido. Por favor, verifica el formato.';
      case 'user-disabled':
        return 'Esta cuenta ha sido deshabilitada. Por favor, contacta al soporte.';
      case 'operation-not-allowed':
        return 'La autenticación por correo electrónico no está habilitada. Por favor, contacta al administrador.';
      case 'network-request-failed':
        return 'Error de conexión. Por favor, verifica tu conexión a internet.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Por favor, espera un momento antes de intentar nuevamente.';
      default:
        return 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
    }
  }
} 
