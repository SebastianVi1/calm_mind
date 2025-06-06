import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Model class representing a user in the application
/// Contains user information and methods to convert from Firebase User
class UserModel {
  /// Unique identifier for the user
  final String uid;

  final FirebaseFirestore db = FirebaseFirestore.instance;
  
  /// User's email address
  final String? email;
  
  /// User's display name
  final String? displayName;
  
  /// URL to user's profile photo
  final String? photoURL;

  /// User's answers to onboarding questions
  /// Stored as a list of strings, one for each question
  final List<String>? questionAnswers;

  /// Flag indicating whether the user has completed the onboarding questions
  /// Used to determine if we need to show the onboarding screen
  final bool hasCompletedQuestions;

  static const int maxPhotoSize = 1000000; // 1MB
  static const int maxDisplayNameLength = 50;
  static const int maxQuestionAnswers = 10;

  /// Constructor for creating a new UserModel
  /// [uid] is required, other fields are optional
  /// [hasCompletedQuestions] defaults to false
  UserModel({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.questionAnswers,
    this.hasCompletedQuestions = false,
  }) {
    _validate();
  }

  void _validate() {
    if (uid.isEmpty) {
      throw ArgumentError('UID cannot be empty');
    }

    if (displayName != null && displayName!.length > maxDisplayNameLength) {
      throw ArgumentError('Display name cannot exceed $maxDisplayNameLength characters');
    }

    if (email != null && !_isValidEmail(email!)) {
      throw ArgumentError('Invalid email format');
    }

    if (photoURL != null && photoURL!.length > maxPhotoSize) {
      throw ArgumentError('Photo URL exceeds maximum size of $maxPhotoSize bytes');
    }

    if (questionAnswers != null && questionAnswers!.length > maxQuestionAnswers) {
      throw ArgumentError('Cannot have more than $maxQuestionAnswers question answers');
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Factory constructor to create a UserModel from a Firebase User
  /// Converts Firebase User data to our application's UserModel
  factory UserModel.fromFirebase(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName ?? (user.isAnonymous ? 'Usuario Anónimo' : null),
      photoURL: user.photoURL,
      hasCompletedQuestions: false, // Default to false for new users
    );
  }

  /// Creates a copy of this UserModel with updated values
  /// Only updates the provided fields, keeps others unchanged
  /// Returns a new instance of UserModel
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    List<String>? questionAnswers,
    bool? hasCompletedQuestions,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      questionAnswers: questionAnswers ?? this.questionAnswers,
      hasCompletedQuestions: hasCompletedQuestions ?? this.hasCompletedQuestions,
    );
  }

  /// Converts the UserModel to a Map for Firebase storage
  /// Used when saving user data to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName ?? (uid.contains('anonymous') ? 'Usuario Anónimo' : null),
      'photoURL': photoURL,
      'questionAnswers': questionAnswers,
      'hasCompletedQuestions': hasCompletedQuestions,
    };
  }

  /// Creates a UserModel from a Map (e.g., from Firebase)
  /// Used when retrieving user data from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      questionAnswers: map['questionAnswers'] != null 
          ? List<String>.from(map['questionAnswers'])
          : null,
      hasCompletedQuestions: map['hasCompletedQuestions'] ?? false,
    );
  }
}
