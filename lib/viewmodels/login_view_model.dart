import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:re_mind/models/auth/auth_state.dart';
import 'package:re_mind/services/auth/i_auth_service.dart';
import 'package:google_sign_in/google_sign_in.dart';
/// ViewModel responsible for handling login and registration operations
/// Implements ChangeNotifier to notify listeners of state changes
class LoginViewModel extends ChangeNotifier {
  /// Service interface for authentication operations
  final IAuthService _authService;
  
  /// Loading state indicator
  bool _isLoading = false;
  
  /// Error message if authentication fails
  String? _error;
  
  /// Current authentication state
  AuthState _state = AuthState();

  /// Constructor that initializes the ViewModel with an auth service
  LoginViewModel(this._authService);

  /// Getter for loading state
  bool get isLoading => _isLoading;
  
  /// Getter for error message
  String? get error => _error;
  
  /// Getter for current authentication state
  AuthState get state => _state;

  /// Attempts to log in a user with email and password
  /// Updates loading state and handles authentication errors
  /// @param email - User's email address
  /// @param password - User's password
  /// @return true if login successful, false otherwise
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      _state = _state.copyWith(status: AuthStatus.loading);
      notifyListeners();

      final user = await _authService.signInWithEmailAndPassword(email, password);
      
      if (user != null) {
        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        
        await Future.delayed(const Duration(milliseconds: 300));
        
        final currentUser = await _authService.getCurrentUser();
        if (currentUser == null) {
          _error = 'La sesión no se pudo mantener. Por favor, intenta nuevamente.';
          _state = _state.copyWith(
            status: AuthStatus.error,
            errorMessage: _error,
          );
          return false;
        }
        
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe una cuenta con este correo electrónico. Por favor, regístrate primero.';
          break;
        case 'wrong-password':
          errorMessage = 'La contraseña es incorrecta.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        case 'user-disabled':
          errorMessage = 'Esta cuenta ha sido deshabilitada.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'La autenticación por correo electrónico no está habilitada. Por favor, contacta al administrador.';
          break;
        default:
          errorMessage = e.message ?? 'Ocurrió un error durante el inicio de sesión.';
      }
      _error = errorMessage;
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: _error,
      );
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: _error,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Attempts to register a new user with email and password
  /// Updates loading state and handles registration errors
  /// @param email - User's email address
  /// @param password - User's password
  /// @param name - User's display name
  /// @return true if registration successful, false otherwise
  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _error = null;
      _state = _state.copyWith(status: AuthStatus.loading);
      notifyListeners();

      final user = await _authService.createUserWithEmailAndPassword(email, password);
      
      if (user != null) {
        // Update the user's display name
        await FirebaseAuth.instance.currentUser?.updateDisplayName(name);
        
        _state = _state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
        return true;
      }
      
      return false;
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Este correo electrónico ya está en uso.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no es válido.';
          break;
        case 'operation-not-allowed':
          errorMessage = 'La autenticación por correo electrónico no está habilitada. Por favor, contacta al administrador.';
          break;
        case 'weak-password':
          errorMessage = 'La contraseña es demasiado débil. Debe tener al menos 6 caracteres.';
          break;
        default:
          errorMessage = e.message ?? 'Ocurrió un error durante el registro.';
      }
      _error = errorMessage;
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: _error,
      );
      return false;
    } catch (e) {
      _error = 'Ocurrió un error inesperado. Por favor, intenta nuevamente.';
      _state = _state.copyWith(
        status: AuthStatus.error,
        errorMessage: _error,
      );
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }
}