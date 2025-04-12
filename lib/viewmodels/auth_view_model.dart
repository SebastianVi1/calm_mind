import 'package:flutter/foundation.dart';
import '../services/auth/i_auth_service.dart';
import '../models/auth/auth_state.dart';
import '../models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// ViewModel responsible for managing authentication state and operations
/// Implements ChangeNotifier to notify listeners of state changes
class AuthViewModel extends ChangeNotifier {
  /// Service interface for authentication operations
  final IAuthService _authService;
  
  /// Current authentication state
  AuthState _state = AuthState();

  /// Constructor that initializes the ViewModel with an auth service
  /// and sets up authentication state listener
  AuthViewModel(this._authService) {
    _init();
  }

  /// Getter for the current authentication state
  AuthState get state => _state;

  /// Initializes the authentication state listener
  /// Listens to auth state changes from Firebase and updates local state accordingly
  void _init() {
    _authService.authStateChanges.listen((user) {
      _state = _state.copyWith(
        status: user != null 
          ? AuthStatus.authenticated 
          : AuthStatus.unauthenticated,
        user: user != null ? UserModel.fromFirebase(user as User) : null,
      );
      notifyListeners();
    });
  }

  /// Signs out the current user
  /// Updates state to reflect sign out status and handles any errors
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      notifyListeners();
    }
  }

  /// Signs in a user with email and password
  /// Updates state to reflect loading, success, or error status
  /// @param email - User's email address
  /// @param password - User's password
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    try {
      _state = _state.copyWith(status: AuthStatus.loading);
      notifyListeners();

      final user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      }
    } catch (e) {
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    } finally {
      notifyListeners();
    }
  }
}

