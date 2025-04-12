import 'package:flutter/material.dart';
import 'package:re_mind/ui/themes/theme_config.dart';

class TTextFieldTheme {
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Themes.lightSurface,
    prefixIconColor: Themes.lightPrimary,
    suffixIconColor: Themes.lightPrimary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.lightPrimary.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.lightPrimary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.lightPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.lightError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.lightError, width: 2),
    ),
    labelStyle: TextStyle(color: Themes.lightOnSurface),
    hintStyle: TextStyle(color: Themes.lightOnSurface.withOpacity(0.6)),
    errorStyle: TextStyle(color: Themes.lightError),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    filled: true,
    fillColor: Themes.darkSurface,
    prefixIconColor: Themes.darkPrimary,
    suffixIconColor: Themes.darkPrimary,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.darkPrimary.withOpacity(0.3)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.darkPrimary.withOpacity(0.3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.darkPrimary, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.darkError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Themes.darkError, width: 2),
    ),
    labelStyle: TextStyle(color: Themes.darkOnSurface),
    hintStyle: TextStyle(color: Themes.darkOnSurface.withOpacity(0.6)),
    errorStyle: TextStyle(color: Themes.darkError),
  );
} 