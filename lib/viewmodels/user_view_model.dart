import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/services/user_service.dart';
import 'package:image/image.dart' as img;

/// ViewModel responsible for managing user-related functionality
/// Handles user profile data, including profile picture management
/// Implements ChangeNotifier to notify listeners of state changes
class UserViewModel extends ChangeNotifier {
  /// User model instance containing user data
  UserModel _userModel;
  
  /// Service for handling user data persistence
  final UserService _userService = UserService();
  
  /// Currently selected image file for profile picture
  File? _selectedImage;
  
  /// Loading state indicator for async operations
  bool _isLoading = false;
  
  /// Error message if any operation fails
  String? _error;

  UserViewModel() : _userModel = UserModel(uid: FirebaseAuth.instance.currentUser?.uid ?? '') {
    _initializeUser();
  }

  Future<void> _initializeUser() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        final userData = await _userService.getUserData(currentUser.uid);
        if (userData != null) {
          _userModel = userData;
          notifyListeners();
        }
      }
    } catch (e) {
      _error = 'Error initializing user data: $e';
      notifyListeners();
    }
  }

  // Getters for accessing private state
  String? get photoURL => _userModel.photoURL;
  File? get selectedImage => _selectedImage;
  bool get isLoading => _isLoading;
  String? get error => _error;
  User get currentUser => FirebaseAuth.instance.currentUser!;

  /// Opens the device's image picker to select a profile picture
  /// Converts the selected image to base64 and updates the user's profile
  /// Handles errors during the selection process
  Future<File?> pickImageFromGallery() async {
    try {
      final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnedImage != null) {
        _selectedImage = File(returnedImage.path);
        
        notifyListeners();
        return _selectedImage;
      }
      
    } catch (e) {
      _error = 'Error al seleccionar la imagen: $e';
      notifyListeners();
    }
    return null;
  }

  /// Updates the user's profile picture in Firestore
  /// Converts the selected image to base64 format
  /// Manages loading state and error handling
  Future<void> updateProfilePicture(File? file) async {
    if (file == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      Uint8List imageBytes = await file.readAsBytes();
      
      img.Image? image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Could not decode image');
      }

      int maxDimension = 800;
      if (image.width > maxDimension || image.height > maxDimension) {
        if (image.width > image.height) {
          image = img.copyResize(image, width: maxDimension);
        } else {
          image = img.copyResize(image, height: maxDimension);
        }
      }

      Uint8List compressedBytes = Uint8List.fromList(img.encodeJpg(image, quality: 85));
      
      if (compressedBytes.length > 1000000) {
        throw Exception('Image is too large even after compression. Please try a smaller image.');
      }

      String base64Image = base64Encode(compressedBytes);
      
      _userModel = _userModel.copyWith(photoURL: base64Image);
      await _userService.saveUserData(_userModel);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error updating profile picture: $e';
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
    var photo =currentUser.photoURL;
    
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

  Future<void> updateUserInfo() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _error = 'No user is currently signed in';
        notifyListeners();
        return;
      }

      if (currentUser.isAnonymous) {
        _error = 'Anonymous users cannot update profile information';
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      _userModel = _userModel.copyWith(
        displayName: currentUser.displayName,
        email: currentUser.email,
      );

      await _userService.saveUserData(_userModel);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error updating user information: $e';
      _isLoading = false;
      notifyListeners();
    }
  }
}

