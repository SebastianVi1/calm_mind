import 'package:flutter/services.dart';

/// Service for providing haptic feedback throughout the app
/// Ensures consistent haptic patterns for similar actions
class HapticsService {
  HapticsService._();

  /// Light impact for subtle interactions (button taps, small UI elements)
  static void light() {
    HapticFeedback.lightImpact();
  }

  /// Medium impact for important actions (selections, confirmations)
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy impact for significant events (errors, major actions)
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  /// Selection click for picker/scrolling interactions
  static void selection() {
    HapticFeedback.selectionClick();
  }

  /// Success pattern for positive confirmations
  static void success() {
    HapticFeedback.mediumImpact();
  }

  /// Error pattern for negative feedback
  static void error() {
    HapticFeedback.heavyImpact();
  }

  /// Pattern for achievement unlocks
  static void achievement() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 150), () {
      HapticFeedback.mediumImpact();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.lightImpact();
    });
  }

  /// Pattern for breathing phase transitions
  static void breathingPhase() {
    HapticFeedback.lightImpact();
  }
}
