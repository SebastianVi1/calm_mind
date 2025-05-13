import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/viewmodels/relaxing_music_view_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> with TickerProviderStateMixin{

    // Store a reference to the ViewModel to avoid context access in dispose
  late final RelaxingMusicViewModel _viewModel;
  
  @override
  void initState() {
    super.initState();
    _viewModel = context.read<RelaxingMusicViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _viewModel.selectedSong != null && !_viewModel.isPlaying) {
        _viewModel.loadAudio();
      }
    });
  }
    @override
  void dispose() {
    // Pausar reproducción de audio antes de desmontar el widget
    // Usar un Future delayed para evitar problemas de actualización en el widget tree
    Future.microtask(() {
      _viewModel.cleanup();
    });
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Consumer<RelaxingMusicViewModel>(
        builder: (context, viewModel, child) {
          
          // verify if there is a song selected
          if (viewModel.selectedSong == null) {
            return const Center(child: Text('No hay canción seleccionada'));
          }
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // background with gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [ Colors.blue[900]!, Colors.purple, Colors.lightBlueAccent],
                  ),
                ),
              ),
                SafeArea(
                top: true,
                bottom: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
               
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: Icon(
                           Icons.arrow_back,
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                    
                    // Song info
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Imagen del álbum (opcional)
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
                                  'assets/animations/relaxing_bg.json',
                                  animate: viewModel.isPlaying ? true : false,
                                ),
                                
                              ),
                            ),
                            const SizedBox(height: 32),
                              // Name of the song
                            Hero(
                              tag: "music-${viewModel.selectedSong?.name ?? 'unknown'}",
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  viewModel.selectedSong?.name ?? 'Desconocido',
                                  style: Theme.of(context).textTheme.displayMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            
                            // Autor
                            Text(
                              viewModel.selectedSong?.author ?? 'Artista desconocido',
                              style: Theme.of(context).textTheme.bodyLarge
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Controles de audio
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                         
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
                          
                          // Tiempos de reproducción
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(viewModel.formatDuration(viewModel.position)),
                                Text(viewModel.formatDuration(viewModel.duration)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                        
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [                              IconButton(
                                icon: const Icon(Icons.skip_previous, size: 36),
                                onPressed: () {
                                  viewModel.previousSong();
                                },
                              ),
                              const SizedBox(width: 16),
                              Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: Icon(
                                    viewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                  iconSize: 48,
                                  onPressed: () {
                                    viewModel.togglePlayPause();
                                  },
                                ),
                              ),
                              const SizedBox(width: 16),
                              IconButton(
                                icon: const Icon(Icons.skip_next, size: 36),
                                onPressed: () {
                                  viewModel.nextSong();
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10,)
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
