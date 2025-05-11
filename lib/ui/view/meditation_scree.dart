import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/viewmodels/meditation_view_model.dart';
import 'package:video_player/video_player.dart';
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
          if (!viewModel.videoInitialized || viewModel.loadingAudio) {              return Center(
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
            children: [
              // Background video
              SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    
                    width: viewModel.videoController.value.size.width,
                    height: viewModel.videoController.value.size.height,
                    child: VideoPlayer(viewModel.videoController),
                  ),
                ),
              ),
              Container(width: double.infinity, height: double.infinity, color: Colors.black.withValues(alpha: 0.1),),
                // Back button
              Positioned(
                top: 30,
                left: 10,
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
              
              // Audio controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        viewModel.formatDuration(viewModel.position), 
                        style: const TextStyle(color: Colors.white)
                      ),
                      Slider(
                        min: 0.0,
                        max: viewModel.duration.inSeconds > 0 ? viewModel.duration.inSeconds.toDouble() : 0.0,
                        value: viewModel.position.inSeconds < viewModel.duration.inSeconds 
                          ? viewModel.position.inSeconds.toDouble() 
                          : viewModel.duration.inSeconds.toDouble(),
                        onChanged: viewModel.handleSeek,
                        activeColor: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            viewModel.formatDuration(viewModel.duration),
                            style: const TextStyle(color: Colors.white)
                          ),
                          IconButton(
                            icon: Icon(
                              viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 48,
                            ),
                            onPressed: viewModel.handlePlayPause,
                          ),
                        ],
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
}