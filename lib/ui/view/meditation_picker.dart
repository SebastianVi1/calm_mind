import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/meditation_audio_model.dart';
import 'package:calm_mind/ui/view/meditation_screen.dart';
import 'package:calm_mind/viewmodels/meditation_view_model.dart';

class MeditationPicker extends StatelessWidget {
  const MeditationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Meditación', style: theme.textTheme.titleMedium),
        centerTitle: true,
        toolbarHeight: 48,
      ),
      body: SafeArea(
        child: Consumer<MeditationViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.meditations.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.self_improvement, size: 48, color: theme.colorScheme.primary.withValues(alpha: 0.5)),
                    const SizedBox(height: 12),
                    Text('Cargando meditaciones...', style: theme.textTheme.bodyLarge),
                  ],
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Destacadas',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: viewModel.meditations.take(5).length,
                    itemBuilder: (context, index) {
                      final meditation = viewModel.meditations[index];
                      return Container(
                        width: 180,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        child: _FeaturedMeditationCard(
                          meditation: meditation,
                          onTap: () => _navigateToMeditation(context, meditation),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'Todas',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: viewModel.meditations.length,
                    itemBuilder: (context, index) {
                      var meditation = viewModel.meditations[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: FadeInRight(
                          config: BaseAnimationConfig(
                            delay: 100.ms,
                            duration: 150.ms,
                            child: _PulsatingMeditationTile(
                              meditation: meditation,
                              onTap: () => _navigateToMeditation(context, meditation),
                              heroTag: "meditation-${meditation.title}",
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _navigateToMeditation(BuildContext context, MeditationAudioModel meditation) {
    final viewModel = Provider.of<MeditationViewModel>(context, listen: false);
    viewModel.setSelectedMeditation(meditation);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeditationScreen()),
    );
  }
}

class _FeaturedMeditationCard extends StatelessWidget {
  final MeditationAudioModel meditation;
  final VoidCallback onTap;

  const _FeaturedMeditationCard({required this.meditation, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFD8B5FF), Color(0xFF1EAE98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1EAE98).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.spa, color: Colors.white, size: 18),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    meditation.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meditation.duration,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget personalizado que muestra una tarjeta de meditación con efecto de pulsación
class _PulsatingMeditationTile extends StatefulWidget {
  final MeditationAudioModel meditation;
  final VoidCallback onTap;
  final String heroTag;

  const _PulsatingMeditationTile({
    required this.meditation,
    required this.onTap,
    required this.heroTag,
  });

  @override
  State<_PulsatingMeditationTile> createState() => _PulsatingMeditationTileState();
}

class _PulsatingMeditationTileState extends State<_PulsatingMeditationTile> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD8B5FF), Color(0xFF1EAE98)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                leading: const CircleAvatar(
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.spa, color: Colors.white),
                ),
                title: Hero(
                  tag: widget.heroTag,
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      widget.meditation.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                subtitle: Text(
                  widget.meditation.duration,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
