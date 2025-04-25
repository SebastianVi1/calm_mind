import 'package:flutter/material.dart';
import 'package:re_mind/ui/themes/elevatedButton_theme.dart';
import 'package:re_mind/ui/themes/text_field_theme.dart';
import 'package:re_mind/ui/themes/text_theme.dart';

class Themes {
  // Colors for light theme
  static const Color lightPrimary = Color(0xFF7C9EC2);
  static const Color lightSecondary = Color(0xFFA8D5BA);
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightError = Color(0xFFB00020);
  static const Color lightOnPrimary = Color(0xFFFFFFFF);
  static const Color lightOnSecondary = Color(0xFF000000);
  static const Color lightOnSurface = Color(0xFF2C3E50);
  static const Color lightOnError = Color(0xFFFFFFFF);

  // Colors for dark theme
  static const Color darkPrimary = Color(0xFF4A6FA5);
  static const Color darkSecondary = Color(0xFF638B74);
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkError = Color(0xFFCF6679);
  static const Color darkOnPrimary = Color(0xFF000000);
  static const Color darkOnSecondary = Color(0xFFFFFFFF);
  static const Color darkOnSurface = Color(0xFFE0E0E0);
  static const Color darkOnError = Color(0xFF000000);

  
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      
      primary: lightPrimary,
      secondary: lightSecondary,
      background: lightBackground,
      surface: lightSurface,
      error: lightError,
      onPrimary: lightOnPrimary,
      onSecondary: lightOnSecondary,
      onSurface: lightOnSurface,
      onError: lightOnError,
    ),
    textTheme: TTextTheme.lightTextTheme,
    elevatedButtonTheme: TElevatedbuttonTheme.elevatedButtonLightTheme,
    inputDecorationTheme: TTextFieldTheme.lightInputDecorationTheme,
    scaffoldBackgroundColor: lightBackground,
    cardTheme: CardTheme(
      color: lightSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    
    appBarTheme: AppBarTheme(
      actionsIconTheme: IconThemeData(
        color: Colors.white
      ),
      centerTitle: true,
      iconTheme: IconThemeData(color: lightOnPrimary,),
      toolbarHeight: 40,
      
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: lightSurface,
      selectedItemColor: lightPrimary,
      unselectedItemColor: lightOnSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: lightPrimary,
      foregroundColor: lightOnPrimary,
      elevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: lightSurface,
      contentTextStyle: TTextTheme.lightTextTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: TTextTheme.lightTextTheme.titleLarge,
      contentTextStyle: TTextTheme.lightTextTheme.bodyMedium,
    ),
    dividerTheme: DividerThemeData(
      color: lightOnSurface.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: lightPrimary,
      circularTrackColor: lightPrimary.withOpacity(0.2),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightSurface,
      selectedColor: lightPrimary,
      labelStyle: TTextTheme.lightTextTheme.bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: darkPrimary,
      secondary: darkSecondary,
      background: darkBackground,
      surface: darkSurface,
      error: darkError,
      onPrimary: darkOnPrimary,
      onSecondary: darkOnSecondary,
      onSurface: darkOnSurface,
      onError: darkOnError,
    ),
    textTheme: TTextTheme.darkTextTheme,
    elevatedButtonTheme: TElevatedbuttonTheme.elevatedButtonDarkTheme,
    inputDecorationTheme: TTextFieldTheme.darkInputDecorationTheme,
    scaffoldBackgroundColor: darkBackground,
    cardTheme: CardTheme(
      color: darkSurface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: darkOnPrimary),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: darkSurface,
      selectedItemColor: darkPrimary,
      unselectedItemColor: darkOnSurface.withOpacity(0.6),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkPrimary,
      foregroundColor: darkOnPrimary,
      elevation: 4,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkSurface,
      contentTextStyle: TTextTheme.darkTextTheme.bodyMedium,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    dialogTheme: DialogTheme(
      backgroundColor: darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      titleTextStyle: TTextTheme.darkTextTheme.titleLarge,
      contentTextStyle: TTextTheme.darkTextTheme.bodyMedium,
    ),
    dividerTheme: DividerThemeData(
      color: darkOnSurface.withOpacity(0.1),
      thickness: 1,
      space: 1,
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: darkPrimary,
      circularTrackColor: darkPrimary.withOpacity(0.2),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkSurface,
      selectedColor: darkPrimary,
      labelStyle: TTextTheme.darkTextTheme.bodyMedium,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}