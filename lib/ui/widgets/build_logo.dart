import 'package:flutter/material.dart';

class WBuildLogo {
  late BuildContext context;
  static Widget buildLogo({double? scale, required BuildContext context}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 25),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Image.asset(
          Theme.of(context).brightness == Brightness.light ? 'assets/images/calm_mind_logo_light.png' : 'assets/images/calm_mind_logo_dark.png',
          scale: scale ?? 8,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

