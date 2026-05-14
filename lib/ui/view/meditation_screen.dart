import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/viewmodels/meditation_view_model.dart';

import 'package:lottie/lottie.dart';

/// A screen that displays a meditation session with video background and audio controls.
/// Handles the display of loading states, error messages, and the meditation interface.
class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  late MeditationViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    // Delayed initialization to ensure context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeViewModel();
    });
  }
  
  void _initializeViewModel() {
    _viewModel = Provider.of<MeditationViewModel>(context, listen: false);
    _viewModel.initializeResources();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = Provider.of<MeditationViewModel>(context, listen: false);
  }
  
  @override
  void dispose() {
    _viewModel.cleanup();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Consumer<MeditationViewModel>(
        builder: (context, viewModel, child) {
          // Show loading screen while resources are being initialized
          if (viewModel.loadingAudio) {
            
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated loading indicator
                  Lottie.asset(
                    'assets/animations/audio_loading.json',
                    width: 150,
                    height: 150,
                  ),
                  
                const SizedBox(height: 16),
                const Text(
                    'Preparando tu sesion de meditacion',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (viewModel.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            viewModel.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton( 
                            onPressed: () => viewModel.initializeResources(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );            
          }            
          // Show main interface when everything is ready
          return Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Colors.blue[900]!, Colors.purple, Colors.black],
                  ),
                ),
              ),
                SafeArea(
                child: Column(
                children: [
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: HugeIcon(
                            icon: HugeIcons.strokeRoundedPictureInPictureExit, 
                            color: Colors.black,
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const Spacer(),
                      if (viewModel.selectedMeditation?.isAiGenerated == true)
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.white70),
                          tooltip: 'Regenerar meditación',
                          onPressed: () {
                            _showRegenerateDialog(context, viewModel);
                          },
                        ),
                    ],
                  ),
                  
                  
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Album Image
                          Container(
                            width: 240,
                            height: 240,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.22),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Lottie.asset(
                                'assets/animations/meditation_bg.json',
                                animate: viewModel.isPlaying ? true : false,
                              ),
                              
                            ),
                          ),
                          const SizedBox(height: 32),                      
                          Hero(
                            tag: "meditation-${viewModel.selectedMeditation?.title ?? 'unknown'}",
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                viewModel.selectedMeditation?.title ?? 'Desconocido',
                                style: Theme.of(context).textTheme.displaySmall,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                           const SizedBox(height: 8),
                           
                           // Breathing Pacer
                           Consumer<MeditationViewModel>(
                             builder: (context, viewModel, child) {
                               if (!viewModel.isPlaying) return const SizedBox.shrink();
                               return Column(
                                 children: [
                                   const Text(
                                     'Sigue el ritmo de tu respiración',
                                     style: TextStyle(color: Colors.white70, fontSize: 16),
                                   ),
                                   const SizedBox(height: 16),
                                   Lottie.asset(
                                     'assets/animations/meditation_bg.json',
                                     width: 100,
                                     height: 100,
                                   ),
                                 ],
                               );
                             },
                           ),
                           const SizedBox(height: 24),
                         ],
                       ),
                     ),
                   ),
                  
                   // Audio Controls
                   ClipRRect(
                     borderRadius: BorderRadius.circular(24),
                     child: BackdropFilter(
                       filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                       child: Container(
                         padding: const EdgeInsets.all(24.0),
                         decoration: BoxDecoration(
                           color: Colors.white.withOpacity(0.1),
                           borderRadius: BorderRadius.circular(24),
                           border: Border.all(
                             color: Colors.white.withOpacity(0.2),
                             width: 1.5,
                           ),
                         ),
                         child: Column(
                           mainAxisSize: MainAxisSize.min,
                           children: [
                             // Progress Slider
                             SliderTheme(
                               data: SliderTheme.of(context).copyWith(
                                 thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                                 overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                                 trackHeight: 4,
                               ),
                               child: Slider(
                                 min: 0.0,
                                 max: viewModel.duration.inSeconds > 0 
                                   ? viewModel.duration.inSeconds.toDouble() 
                                   : 0.0,
                                 value: viewModel.position.inSeconds < viewModel.duration.inSeconds 
                                   ? viewModel.position.inSeconds.toDouble() 
                                   : viewModel.duration.inSeconds.toDouble(),
                                 onChanged: viewModel.handleSeek,
                               ),
                              ),
                              
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(viewModel.formatDuration(viewModel.position), 
                                      style: const TextStyle(color: Colors.white70)),
                                    Text(viewModel.formatDuration(viewModel.duration),
                                      style: const TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.skip_previous, size: 36, color: Colors.white),
                                    onPressed: () {
                                      viewModel.previousMeditation();
                                    },
                                  ),
                                  const SizedBox(width: 16),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.4),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: IconButton(
                                      icon: Icon(
                                        viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      iconSize: 48,
                                      onPressed: () {
                                        viewModel.handlePlayPause();
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  IconButton(
                                    icon: const Icon(Icons.skip_next, size: 36, color: Colors.white),
                                    onPressed: () {
                                      viewModel.nextMeditation();
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10,)
                            ],
                          ),
                        ),
                      ),
                    ),
                
                ],
              ),
              ),
              if (viewModel.isGenerating || viewModel.loadingAudio)
                Container(
                  color: Colors.black54,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          viewModel.isGenerating
                              ? 'Generando audio con IA...'
                              : 'Cargando...',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showRegenerateDialog(
      BuildContext context, MeditationViewModel viewModel) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Regenerar meditación'),
        content: const Text(
          '¿Regenerar esta meditación? Esto eliminará el audio guardado y generará nuevo contenido con IA.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              viewModel.regenerateAll();
            },
            child: const Text('Regenerar'),
          ),
        ],
      ),
    );
  }
}
