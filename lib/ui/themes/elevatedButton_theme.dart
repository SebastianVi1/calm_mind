import 'package:flutter/material.dart';
import 'package:re_mind/ui/themes/theme_config.dart';

class TElevatedbuttonTheme {
  static final ElevatedButtonThemeData elevatedButtonLightTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.resolveWith<double>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) return 0;
          if (states.contains(WidgetState.disabled)) return 0;
          return 4;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Themes.lightPrimary.withOpacity(0.5);
          }
          return Themes.lightPrimary;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Themes.lightOnPrimary.withOpacity(0.5);
          }
          return Themes.lightOnPrimary;
        },
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Themes.lightOnPrimary.withOpacity(0.1);
          }
          return Colors.transparent;
        },
      ),
    ),
  );

  static final ElevatedButtonThemeData elevatedButtonDarkTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStateProperty.resolveWith<double>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) return 0;
          if (states.contains(WidgetState.disabled)) return 0;
          return 4;
        },
      ),
      backgroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Themes.darkPrimary.withOpacity(0.5);
          }
          return Themes.darkPrimary;
        },
      ),
      foregroundColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.disabled)) {
            return Themes.darkOnPrimary.withOpacity(0.5);
          }
          return Themes.darkOnPrimary;
        },
      ),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      overlayColor: WidgetStateProperty.resolveWith<Color>(
        (Set<WidgetState> states) {
          if (states.contains(WidgetState.pressed)) {
            return Themes.darkOnPrimary.withOpacity(0.1);
          }
          return Colors.transparent;
        },
      ),
    ),
  );
}