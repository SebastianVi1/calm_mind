import '../user_model.dart';

/// Enum representing the possible authentication states
enum AuthStatus { 
  /// Initial state when the app starts
  initial,
  
  /// User is successfully authenticated
  authenticated,
  
  /// User is not authenticated
  unauthenticated,
  
  /// Authentication operation in progress
  loading,
  
  /// An error occurred during authentication
  error 
}

/// Class representing the authentication state of the application
/// Contains the current status, user information, and error messages
class AuthState {
  /// Current authentication status
  final AuthStatus status;
  
  /// Current user information if authenticated
  final UserModel? user;
  
  /// Error message if status is error
  final String? errorMessage;

  /// Constructor for AuthState
  /// [status] defaults to initial
  /// [user] and [errorMessage] are optional
  AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  /// Creates a new AuthState with updated values
  /// Only updates the provided fields, keeps others unchanged
  /// Returns a new instance of AuthState
  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
} 