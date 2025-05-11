import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/viewmodels/relaxing_music_view_model.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({super.key});

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen> {
  @override
  void initState() {
    super.initState();
    // Inicializar audio cuando la pantalla se abre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<RelaxingMusicViewModel>();
      if (viewModel.selectedSong != null && !viewModel.isPlaying) {
        viewModel.loadAudio();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<RelaxingMusicViewModel>(
        builder: (context, viewModel, child) {
          // Verificar si hay una canción seleccionada
          if (viewModel.selectedSong == null) {
            return const Center(child: Text('No hay canción seleccionada'));
          }
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Fondo con imagen o gradiente (opcional)
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.blue.shade200, Colors.purple.shade200],
                  ),
                ),
              ),
              
              // Contenido principal
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Botón de regreso
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
                    
                    // Información de la canción
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
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.music_note, size: 80, color: Colors.white),
                            ),
                            const SizedBox(height: 32),
                            
                            // Nombre de la canción
                            Text(
                              viewModel.selectedSong?.name ?? 'Desconocido',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            
                            // Autor
                            Text(
                              viewModel.selectedSong?.author ?? 'Artista desconocido',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Controles de audio
                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.05),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Barra de progreso
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
                          
                          // Controles de reproducción
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.skip_previous, size: 36),
                                onPressed: () {
                                  // Implementar función para ir a la canción anterior
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
                                  // Implementar función para ir a la siguiente canción
                                },
                              ),
                            ],
                          ),
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