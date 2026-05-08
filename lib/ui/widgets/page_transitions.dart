import 'package:flutter/material.dart';
import 'package:calm_mind/ui/constants/animation_constants.dart';

/// Professional page transition with fade and slide
Route<T> createProfessionalRoute<T>(Widget page, {bool slideFromRight = true}) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: AppAnimations.enter,
      );

      return FadeTransition(
        opacity: curve,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: Offset(slideFromRight ? 0.1 : -0.1, 0),
            end: Offset.zero,
          ).animate(curve),
          child: child,
        ),
      );
    },
    transitionDuration: AppAnimations.medium,
    reverseTransitionDuration: AppAnimations.short,
  );
}

/// Extension for easy page transition usage
extension PageTransitionExtension on BuildContext {
  Future<T?> pushProfessional<T>(Widget page) {
    return Navigator.push<T>(
      this,
      createProfessionalRoute<T>(page),
    );
  }

  Future<T?> pushProfessionalFromRight<T>(Widget page) {
    return Navigator.push<T>(
      this,
      createProfessionalRoute<T>(page, slideFromRight: true),
    );
  }

  Future<T?> pushProfessionalFromLeft<T>(Widget page) {
    return Navigator.push<T>(
      this,
      createProfessionalRoute<T>(page, slideFromRight: false),
    );
  }
}
