import 'package:flutter/material.dart';

class BuildBackground {
  static Widget backgroundWelcomeScreen(String imagePath) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}