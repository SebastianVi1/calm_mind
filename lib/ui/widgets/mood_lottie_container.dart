import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:calm_mind/models/mood_model.dart';
import 'package:calm_mind/ui/constants/animation_constants.dart';

class WMoodLottieContainer extends StatefulWidget {
  final MoodModel mood;
  final bool isSelected;
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

class _MoodLottieContainerState extends State<WMoodLottieContainer>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: AppAnimations.short,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.smooth),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: AppAnimations.smooth),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(WMoodLottieContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _controller.forward(from: 0);
      _scaleController.forward();
      HapticFeedback.mediumImpact();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _scaleController.reverse();
    }
  }

  void _handleTap() {
    if (!widget.isSelected) {
      _controller.forward(from: 0);
      widget.onTap();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _scaleController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: AppAnimations.short,
                  curve: AppAnimations.smooth,
                  width: 70,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.mood.color.withValues(
                        alpha: 0.3 + (_borderAnimation.value * 0.7),
                      ),
                      width: 2 + (_borderAnimation.value * 2),
                    ),
                    boxShadow: widget.isSelected
                        ? [
                            BoxShadow(
                              color: widget.mood.color.withValues(alpha: 0.3),
                              blurRadius: 12 + (_borderAnimation.value * 8),
                              spreadRadius: 2 + (_borderAnimation.value * 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Lottie.asset(
                    widget.mood.lottieAsset,
                    controller: _controller,
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedDefaultTextStyle(
                  duration: AppAnimations.short,
                  curve: AppAnimations.smooth,
                  style: TextStyle(
                    color: widget.isSelected
                        ? widget.mood.color
                        : Colors.grey.withValues(alpha: 0.7),
                    fontWeight:
                        widget.isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                  child: Text(widget.mood.label),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
