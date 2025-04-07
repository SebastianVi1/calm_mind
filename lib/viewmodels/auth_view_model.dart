// lib/view_models/auth_view_model.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  User? _user;

  AuthViewModel(this._authService);

  User? get user => _user;

  Future<void> signInAnonymously() async {
    try {
      final userCredential = await _authService.signInAnonymously();
      _user = userCredential.user;
      notifyListeners();
    } catch (e) {
      print('Error signing in anonymously: $e');
    }
  }

  bool isAnonymousUser() {
    return _authService.isAnonymousUser(_user!);
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}