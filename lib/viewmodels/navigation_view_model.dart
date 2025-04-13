import 'package:flutter/material.dart';

/// ViewModel para manejar la navegación de la aplicación
class NavigationViewModel extends ChangeNotifier {
  int _currentIndex = 0;
  
  /// Obtiene el índice actual de la navegación
  int get currentIndex => _currentIndex;
  
  /// Cambia el índice actual de la navegación
  void changeIndex(int index) {
    if (_currentIndex != index) {
      _currentIndex = index;
      notifyListeners();
    }
  }
} 