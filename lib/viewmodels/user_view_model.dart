import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:re_mind/models/user_model.dart';
import 'package:re_mind/services/user_service.dart';

/// ViewModel responsible for managing user-related functionality
/// Handles user profile data, including profile picture management
/// Implements ChangeNotifier to notify listeners of state changes
class UserViewModel extends ChangeNotifier {
  /// User model instance containing user data
  final UserModel _userModel = UserModel(uid: FirebaseAuth.instance.currentUser!.uid);
  
  /// Service for handling user data persistence
  final UserService _userService = UserService();
  
  /// Currently selected image file for profile picture
  File? _selectedImage;
  
  /// Loading state indicator for async operations
  bool _isLoading = false;
  
  /// Error message if any operation fails
  String? _error;

  // Getters for accessing private state
  String? get photoURL => _userModel.photoURL;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User get currentUser => FirebaseAuth.instance.currentUser!;

  /// Opens the device's image picker to select a profile picture
  /// Converts the selected image to base64 and updates the user's profile
  /// Handles errors during the selection process
  Future<void> pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnedImage != null) {
        _selectedImage = File(returnedImage.path);
        await _updateProfilePicture();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error al seleccionar la imagen: $e';
      notifyListeners();
    }
  }

  /// Updates the user's profile picture in Firestore
  /// Converts the selected image to base64 format
  /// Manages loading state and error handling
  Future<void> _updateProfilePicture() async {
    if (_selectedImage == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Convert image to base64 for storage
      List<int> imageBytes = await _selectedImage!.readAsBytes();
      String base64Image = base64Encode(imageBytes);
      
      // Update user model with new photo URL
      _userModel.copyWith(photoURL: base64Image);
      
      // Persist changes to Firestore
      await _userService.saveUserData(_userModel);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar la foto de perfil: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the appropriate ImageProvider based on the current state
  /// Priority order:
  /// 1. Currently selected image (if any)
  /// 2. Base64 encoded image from Firestore (if any)
  /// 3. Default blank profile picture
  ImageProvider getProfileImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (photoURL != null) {
      try {
        final bytes = base64Decode(photoURL!);
        return MemoryImage(bytes);
      } catch (e) {
        return const AssetImage('assets/images/blank_profile_picture.webp');
      }
    }
    return const AssetImage('assets/images/blank_profile_picture.webp');
  }
}

