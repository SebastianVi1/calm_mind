import 'package:flutter/material.dart';

class AppConstants {
  // Animation durations
  static const Duration textAnimationDuration = Duration(milliseconds: 100);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);

  // Colors
  static const Color selectedOptionColor = Colors.blue;
  static const Color unselectedOptionColor = Colors.purple;
  
  // Dimensions
  static const double optionButtonHeight = 50.0;
  static const double optionButtonVerticalPadding = 15.0;
  static const double optionButtonVerticalMargin = 8.0;
  static const double contentHorizontalPadding = 20.0;
  static const double topSpacing = 30.0;
  static const double bottomSpacing = 20.0;
  static const double optionsSpacing = 0.3; // 30% of screen height

  // Strings
  static const String nextQuestionText = 'Siguiente pregunta';
  static const String backgroundImagePath = 'assets/images/questions_background.jpg';
  static const String backgroundMainImagePath = 'assets/images/background_main.jpg';
  static const String appName = 'CalmMind';
  static const String appSlogan = 'Relaja tu mente, calma tu ser';
  static const String continueWithoutUser = 'Continua sin usuario';
  static const String loginButtonText = 'Iniciar sesión';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String welcomeText = 'Bienvenido de nuevo';
  static const String loginRequiredText = 'Inicia sesión para continuar';
} 