import 'package:calm_mind/models/user_model.dart';

abstract class IAuthService {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel?> getCurrentUser();
  Future<UserModel?> signInWithEmailAndPassword(String email, String password);
  Future<UserModel?> createUserWithEmailAndPassword(String email, String password);
  Future<void> signOut();
} 
