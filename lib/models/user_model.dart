import 'package:firebase_auth/firebase_auth.dart';

/// Model class representing a user in the application
/// Contains user information and methods to convert from Firebase User
class UserModel {
  /// Unique identifier for the user
  final String uid;
  
  /// User's email address
  final String? email;
  
  /// User's display name
  final String? displayName;
  
  /// URL to user's profile photo
  final String? photoURL;

  /// Constructor for creating a new UserModel
  /// [uid] is required, other fields are optional
  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
  });

  /// Factory constructor to create a UserModel from a Firebase User
  /// Converts Firebase User data to our application's UserModel
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
    );
  }
}
