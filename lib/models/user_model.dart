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
      'displayName': displayName,
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
