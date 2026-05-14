import 'package:flutter/material.dart';

/// Design tokens for consistent animations throughout the app
class AppAnimations {
  AppAnimations._();

  // Duration tokens
  static const Duration micro = Duration(milliseconds: 150);
  static const Duration short = Duration(milliseconds: 300);
  static const Duration medium = Duration(milliseconds: 500);
  static const Duration long = Duration(milliseconds: 800);
  static const Duration breathing = Duration(seconds: 19);
  
  // Curve tokens
  static const Curve smooth = Curves.easeInOut;
  static const Curve enter = Curves.easeOutCubic;
  static const Curve exit = Curves.easeInCubic;
  static const Curve spring = Curves.easeOutBack;
  static const Curve gentle = Curves.easeOut;
  
  // Preset animations
  static Animation<double> fadeIn(
    AnimationController controller, {
    double begin = 0.0,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: enter),
    );
  }
  
  static Animation<double> fadeOut(
    AnimationController controller, {
    double begin = 1.0,
    double end = 0.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: exit),
    );
  }
  
  static Animation<double> scaleIn(
    AnimationController controller, {
    double begin = 0.95,
    double end = 1.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: smooth),
    );
  }
  
  static Animation<double> slideUp(
    AnimationController controller, {
    double begin = 20.0,
    double end = 0.0,
  }) {
    return Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: controller, curve: enter),
    );
  }
}
