// lib/ui/widgets/mood_lottie_button.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:calm_mind/models/mood_model.dart';

// A widget that displays a mood animation using Lottie and handles selection state
class WMoodLottieContainer extends StatefulWidget {
  // The mood data to display
  final MoodModel mood;
  // Whether this mood is currently selected
  final bool isSelected;
  // Callback function when the mood is tapped
  final VoidCallback onTap;

  const WMoodLottieContainer({
    super.key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<WMoodLottieContainer> createState() => _MoodLottieContainerState();
}

// State class for the mood lottie container
class _MoodLottieContainerState extends State<WMoodLottieContainer> 
    with SingleTickerProviderStateMixin {
  // Controller for the Lottie animation
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the animation controller with a duration of 1 second
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    // Clean up the animation controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  // Handle tap events on the mood container
  void _handleTap() {
    if (!widget.isSelected) {
      // Play the animation from the beginning when tapped
      _controller.forward(from: 0);
      // Trigger the onTap callback
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Container for the Lottie animation
          Container(
            width: 70,  // Fixed width for the container
            height: 80, // Fixed height for the container
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Add a colored border when selected
              border: widget.isSelected 
                ? Border.all(color: widget.mood.color, width: 3)
                : null,
            ),
            child: Lottie.asset(
              widget.mood.lottieAsset,
              controller: _controller,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          // Display the mood label below the animation
          Text(
            widget.mood.label,
            style: TextStyle(
              // Change text color and weight when selected
              color: widget.isSelected ? widget.mood.color : Colors.grey,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        
          
        ],
      ),
    );
  }
}
