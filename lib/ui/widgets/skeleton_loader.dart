import 'package:flutter/material.dart';

/// A shimmer loading skeleton for content placeholders
class WSkeletonLoader extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const WSkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
  });

  @override
  State<WSkeletonLoader> createState() => _WSkeletonLoaderState();
}

class _WSkeletonLoaderState extends State<WSkeletonLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceVariant;
    final highlightColor = colorScheme.surface;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            shape: widget.shape,
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              stops: const [0.0, 0.5, 1.0],
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              transform: GradientRotation(_animation.value),
            ),
          ),
        );
      },
    );
  }
}

/// Pre-built skeleton shapes for common use cases
class WSkeleton {
  static Widget line({double? width, double height = 16}) {
    return WSkeletonLoader(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(4),
    );
  }

  static Widget circle({double size = 40}) {
    return WSkeletonLoader(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }

  static Widget card() {
    return WSkeletonLoader(
      height: 120,
      borderRadius: BorderRadius.circular(12),
    );
  }

  static Widget avatar({double size = 50}) {
    return WSkeletonLoader(
      width: size,
      height: size,
      shape: BoxShape.circle,
    );
  }
}
