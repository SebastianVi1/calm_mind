import 'package:flutter/material.dart';
import 'package:re_mind/ui/constants/app_constants.dart';

class BuildBackground {
  static Widget backgroundWelcomeScreen() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(AppConstants.backgroundImagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}