import 'package:flutter/material.dart';

class WAnimatedTipCard extends StatefulWidget {
  final String title;
  final String content;
  final String category;
  final VoidCallback onTap;
  final bool isFavorite;
  final int index;

  const WAnimatedTipCard({
    super.key,
    required this.title,
    required this.content,
    required this.category,
    required this.onTap,
    required this.isFavorite,
    required this.index,
  });

  @override
  State<WAnimatedTipCard> createState() => WAnimatedTipCardState();
}

class WAnimatedTipCardState extends State<WAnimatedTipCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  static const _staggeredDelay = 50; // Reducido de 30 a 50ms para menos animaciones simultáneas

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300 + (widget.index * _staggeredDelay).clamp(0, 300)),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    // Usar un Future para evitar animaciones simultáneas
    Future.delayed(Duration(milliseconds: widget.index * _staggeredDelay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(100 * (1 - _animation.value), 0),
          child: Opacity(
            opacity: _animation.value,
            child: _TipCard(
              title: widget.title,
              content: widget.content,
              category: widget.category,
              onTap: widget.onTap,
              isFavorite: widget.isFavorite,
            ),
          ),
        );
      },
    );
  }
}

class _TipCard extends StatelessWidget {
  final String title;
  final String content;
  final String category;
  final VoidCallback onTap;
  final bool isFavorite;

  const _TipCard({
    required this.title,
    required this.content,
    required this.category,
    required this.onTap,
    required this.isFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Categoría con chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Botón de favorito con animación mejorada
                  FavoriteButton(
                    isFavorite: isFavorite,
                    onTap: onTap,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Título
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              // Contenido
              Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;

  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onTap,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  static const _animationDuration = 150; // Reducido de 200 a 150ms

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: _animationDuration),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate( // Reducido de 1.3 a 1.2
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
  }

  void handleTap() {
    if (!_controller.isAnimating) { // Evitar animaciones superpuestas
      _controller.forward().then((_) => _controller.reverse());
      widget.onTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: handleTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Icon(
              widget.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite 
                ? colorScheme.error 
                : colorScheme.onSurface.withOpacity(0.5),
              size: 28,
            ),
          );
        },
      ),
    );
  }
} 