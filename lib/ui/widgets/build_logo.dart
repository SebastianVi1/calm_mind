import 'package:flutter/material.dart';

class WBuildLogo {
  static Widget buildLogo({double? scale}) {
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
          'assets/images/remind_logo.jpg',
          scale: scale ?? 8,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

