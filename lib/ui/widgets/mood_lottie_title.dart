import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// A widget that displays a Lottie animation based on a mood value.
/// The animation changes according to the following ranges:
/// - Happy: value >= 4.0
/// - Neutral: value >= 2.5
/// - Angry: value >= 1.5
/// - Sad: value < 1.5
class MoodLottieTitle extends StatelessWidget {
  /// The mood value that determines which animation to show
  final double value;

  /// The size of the animation container
  final double size;

  /// Creates a new MoodLottieTitle widget
  const MoodLottieTitle({
    super.key,
    required this.value,
    this.size = 30,
  });

  @override
  Widget build(BuildContext context) {
    String lottieAsset;
    if (value >= 4.0) {
      lottieAsset = 'assets/animations/happy_emoji.json'; // Happy
    } else if (value >= 2.5) {
      lottieAsset = 'assets/animations/neutral_emoji.json'; // Neutral
    } else if (value >= 1.5) {
      lottieAsset = 'assets/animations/angry_emoji.json'; // Angry
    } else {
      lottieAsset = 'assets/animations/sad_emoji.json'; // Sad
    }

    return SizedBox(
      width: size,
      height: size,
      child: Lottie.asset(
        lottieAsset,
        fit: BoxFit.contain,
      ),
    );
  }
} 