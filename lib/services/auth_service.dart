// lib/services/auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Método para iniciar sesión anónimamente
  Future<UserCredential> signInAnonymously() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // errores de autenticación
      throw Exception('Error signing in anonymously: ${e.message}');
    }
  }

  // Método para verificar si el usuario está autenticado anónimamente
  bool isAnonymousUser(User user) {
    return user != null && user.isAnonymous;
  }

  // Método para cerrar la sesión del usuario
  Future<void> signOut() async {
    await _auth.signOut();
  }
}