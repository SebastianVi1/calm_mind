import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/meditation_audio_model.dart';
import 'package:calm_mind/ui/view/meditation_scree.dart';
import 'package:calm_mind/viewmodels/meditation_view_model.dart';

class MeditationPicker extends StatelessWidget {
  const MeditationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Text(
              'Selecciona la meditacion que deseasescuchar',
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            Consumer<MeditationViewModel>(
              
              builder: (context, viewModel, child) {
                
                return Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.urls.length,
                    itemBuilder: (context, index) {
                      var meditation = viewModel.urls[index];                      
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
                );
              },
              
            ),
          ],
        ),
      ),
    );
  }

   void _navigateToMeditation(BuildContext context, MeditationAudioModel meditation) {
    // Set the selected meditation in the ViewModel
    final viewModel = Provider.of<MeditationViewModel>(context, listen: false);
    viewModel.setSelectedMeditation(meditation);
    
    // Navigate to meditation screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeditationScreen()),
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
