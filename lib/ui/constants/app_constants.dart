import 'package:flutter/material.dart';

class AppConstants {
  AppConstants._();

  // ── Animation Durations ──
  static const Duration textAnimationDuration = Duration(milliseconds: 100);
  static const Duration pageTransitionDuration = Duration(milliseconds: 300);
  static const Duration shortAnim = Duration(milliseconds: 200);
  static const Duration mediumAnim = Duration(milliseconds: 400);
  static const Duration longAnim = Duration(milliseconds: 800);

  // ── Theme Colors ──
  static const Color colorPrimary = Color(0xFF8EACCD);
  static const Color colorSecondary = Color(0xFFC3E8B3);
  static const Color colorAccent = Color(0xFF5C7C9D);

  // ── Semantic Colors ──
  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color errorColor = Color(0xFFE57373);
  static const Color infoColor = Color(0xFF2196F3);

  // ── Gradients ──
  static const List<Color> meditationGradient = [Color(0xFFD8B5FF), Color(0xFF1EAE98)];
  static const List<Color> musicGradient = [Color(0xFF9D4EDD), Color(0xFFFF9100)];
  static const List<Color> forumHeaderGradient = [Color(0xFF2D1B69), Color(0xFF1A1A2E)];

  // ── Border Radius ──
  static const double radiusXs = 6.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 20.0;
  static const double radius2xl = 24.0;
  static const double radiusFull = 999.0;

  // ── Spacing ──
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 20.0;
  static const double space2xl = 24.0;
  static const double space3xl = 32.0;

  // ── Component Sizes ──
  static const double buttonHeight = 50.0;
  static const double fabSize = 56.0;
  static const double iconSizeSm = 18.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
  static const double avatarRadiusSm = 18.0;
  static const double avatarRadiusMd = 24.0;
  static const double avatarRadiusLg = 32.0;

  // ── Card / Container ──
  static const double cardElevation = 0.0;
  static const double contentHorizontalPadding = 20.0;
  static const double topSpacing = 30.0;
  static const double bottomSpacing = 20.0;
  static const double optionsSpacing = 0.3;
  static const double navBarHeight = 70.0;
  static const double fabBottomOffset = 90.0;

  // ── Opacity Levels ──
  static const double opacitySubtle = 0.05;
  static const double opacityLight = 0.1;
  static const double opacityMedium = 0.2;
  static const double opacityStrong = 0.5;

  // ── Strings (Spanish) ──
  static const String appName = 'CalmMind';
  static const String appSlogan = 'Relaja tu mente, calma tu ser';
  static const String continueWithoutUser = 'Continua sin usuario';
  static const String loginButtonText = 'Iniciar sesión';
  static const String emailLabel = 'Correo electrónico';
  static const String passwordLabel = 'Contraseña';
  static const String welcomeText = 'Bienvenido de nuevo';
  static const String loginRequiredText = 'Inicia sesión para continuar';
  static const String nextQuestionText = 'Siguiente pregunta';

  // ── Assets ──
  static const String loadingAnimation = 'assets/animations/loading.json';
  static const String meditationRoomAnimation = 'assets/animations/meditation_room.json';
  static const String musicAnimation = 'assets/animations/music_hearing.json';
  static const String focusBrainAnimation = 'assets/animations/focus_brain.json';
}
