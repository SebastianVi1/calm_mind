import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class MeditationScreen extends StatefulWidget {
  const MeditationScreen({super.key});

  @override
  State<MeditationScreen> createState() => _MeditationScreenState();
}

class _MeditationScreenState extends State<MeditationScreen> {
  final player = AudioPlayer();
  Duration position = Duration.zero;
  Duration duration = Duration.zero;
  String? errorMessage;
  bool loadingAudio = true;
  
  String formatDuration(Duration d){
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2,'0')}";
  }

  void handlePlayPause(){
    if (player.playing){
      player.pause();
    } else {
      player.play();
    }
    setState(() {}); // Add setState here to refresh UI
  }

  void handleSeek(double value){
    player.seek(Duration(seconds: value.toInt()));
  }
  
  @override
  void initState(){
    super.initState();
    
    loadAudio();
    
    //Listen to position updates
    player.positionStream.listen((p) {
      setState(() {
        position = p;
      });
    });
    //Listen to duration updates
    player.durationStream.listen((d){
      setState(() {
        duration = d ?? Duration.zero;
        loadingAudio = false;
      });
    });
    player.playerStateStream.listen((state){
      if (state.processingState == ProcessingState.completed) {
        setState(() {
          position = Duration.zero;
        });
        player.pause();
        player.seek(position);
      }
    });
    
    // Escuchar errores
    player.errorStream.listen((error) {
      setState(() {
        errorMessage = "Error: ${error.message} (código: ${error.code})";
        loadingAudio = false;
      });
      print("ERROR DE AUDIO: ${error.message}");
    });
  }
  
  Future<void> loadAudio() async {
    try {
      setState(() {
        loadingAudio = true;
        errorMessage = null;
      });
      
      // Intenta cargar el audio con wait: true para esperar a que se cargue completamente
      await player.setUrl('https://cdn.pixabay.com/download/audio/2025/04/25/audio_a37120f89e.mp3?filename=wide-flower-fields-atmospheric-ambient-332274.mp3');
      
      setState(() {
        loadingAudio = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error al cargar el audio: $e";
        loadingAudio = false;
      });
      print("ERROR DE CARGA: $e");
    }
  }
  
  @override
  void dispose() {
    player.dispose(); // Importante liberar recursos cuando el widget se destruye
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meditación'),
      ),
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (loadingAudio)
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
              
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              
            if (!loadingAudio && errorMessage == null) ...[
              Text(
                formatDuration(position), 
                style: const TextStyle(color: Colors.white)
              ),
              Slider(
                min: 0.0,
                max: duration.inSeconds > 0 ? duration.inSeconds.toDouble() : 0.0,
                value: position.inSeconds < duration.inSeconds ? position.inSeconds.toDouble() : duration.inSeconds.toDouble(),
                onChanged: handleSeek,
                activeColor: Colors.white,
              ),
              Text(
                formatDuration(duration),
                style: const TextStyle(color: Colors.white)
              ),
              IconButton(
                icon: Icon(
                  player.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 48,
                ),
                onPressed: handlePlayPause,
              )
            ],
            
            // Botón para reintentar cargar el audio
            if (errorMessage != null)
              ElevatedButton(
                onPressed: loadAudio,
                child: const Text('Reintentar'),
              ),
          ],
        ),
      ),
    );
  }
}