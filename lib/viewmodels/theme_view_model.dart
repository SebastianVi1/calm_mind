import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeViewModel extends ChangeNotifier {
  // Flag to determine if we should use system theme
  bool _useSystemTheme = true;
  // Flag to determine if dark mode is enabled
  bool _isDarkMode = false;

  // Getter for system theme preference
  bool get useSystemTheme => _useSystemTheme;
  // Getter for dark mode state
  bool get isDarkMode => _isDarkMode;
  // Getter for current active theme state (system or manual)
  bool get isDarkModeActive => _useSystemTheme 
    ? WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark
    : _isDarkMode;

  ThemeViewModel() {
    _loadThemePreferences();
    // Listen to changes in the system theme
    WidgetsBinding.instance.platformDispatcher.onPlatformBrightnessChanged = () {
      if (_useSystemTheme) {
        notifyListeners();
      }
    };
  }

  // Load theme preferences from SharedPreferences
  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _useSystemTheme = prefs.getBool('useSystemTheme') ?? true;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Toggle between system theme and manual dark mode
  Future<void> toggleTheme() async {
    _useSystemTheme = !_useSystemTheme;
    if (!_useSystemTheme) {
      _isDarkMode = true;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useSystemTheme', _useSystemTheme);
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  // Force the app to use system theme
  Future<void> setSystemTheme() async {
    _useSystemTheme = true;
    _isDarkMode = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('useSystemTheme', _useSystemTheme);
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
} 
