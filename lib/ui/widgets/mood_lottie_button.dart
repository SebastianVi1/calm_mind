// lib/ui/widgets/mood_lottie_button.dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:re_mind/models/mood_model.dart';

class WMoodLottieButton extends StatefulWidget {
  final MoodModel mood;
  final bool isSelected;
  final VoidCallback onTap;

  const WMoodLottieButton({
    Key? key,
    required this.mood,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<WMoodLottieButton> createState() => _MoodLottieButtonState();
}

class _MoodLottieButtonState extends State<WMoodLottieButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (!widget.isSelected) {
      _controller.forward(from: 0);  // Reproduce la animación desde el inicio
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
          Container(
            width: 70,  // Ajusta según necesites
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
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
          Text(
            widget.mood.label,
            style: TextStyle(
              color: widget.isSelected ? widget.mood.color : Colors.grey,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}