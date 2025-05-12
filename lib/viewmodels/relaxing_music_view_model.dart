import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:re_mind/services/relaxing_music_service.dart';
import 'package:re_mind/models/relaxing_music_model.dart';

enum RelaxingMusicState {
  initial,
  loading,
  loaded,
  error
}

class RelaxingMusicViewModel extends ChangeNotifier {
  final RelaxingMusicService _relaxingMusicService;
  RelaxingMusicState _state = RelaxingMusicState.initial;
  RelaxingMusicState get state => _state;

  List<RelaxingMusicModel> _musicList = [];
  List<RelaxingMusicModel> get musicList => _musicList;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  RelaxingMusicModel? _selectedSong;
  RelaxingMusicModel? get selectedSong => _selectedSong;

  // Audio player properties and state
  late AudioPlayer _player;
  bool _loadingAudio = false;
  bool get loadingAudio => _loadingAudio;
  Duration _position = Duration.zero;
  Duration get position => _position;
  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  bool get isPlaying => _player.playing;
  
  // Track initialization and disposal state
  bool _isInitialized = false;
  bool _isDisposed = false;

  RelaxingMusicViewModel(this._relaxingMusicService) {
    _player = AudioPlayer();
    _initializeAudioListeners();
    getMusic();
  }

  // Initialize audio player listeners
  void _initializeAudioListeners() {
    _player.positionStream.listen((p) {
      if (_isDisposed) return;
      _position = p;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      if (_isDisposed) return;
      _duration = d ?? Duration.zero;
      _loadingAudio = false;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      if (_isDisposed) return;
      
      if (state.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _player.pause();
        _player.seek(_position);
        notifyListeners();
      }
    });    // Listen for errors
    _player.playbackEventStream.listen((event) {}, 
      onError: (Object e, StackTrace stackTrace) {
        if (_isDisposed) return;
        _errorMessage = "Error de reproduccion: $e";
        _loadingAudio = false;
        notifyListeners();
      }
    );


  }
  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2,'0')}";
  }  void handleSeek(double value) {
    _player.seek(Duration(seconds: value.toInt()));
  }
    void nextSong() {
    if (_isDisposed || _selectedSong == null || _musicList.isEmpty) return;
    
    try {
      // Find the index of the current song
      final currentIndex = _musicList.indexWhere((song) => 
        song.name == _selectedSong!.name && song.url == _selectedSong!.url);
      
      // If found, select the next song or loop back to the first one
      if (currentIndex != -1) {
        final nextIndex = (currentIndex + 1) % _musicList.length;
        _selectedSong = _musicList[nextIndex];
        loadAudio();
      }
      
      // Solo notificar si el objeto no ha sido eliminado
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error al cambiar a la siguiente canción: $e');
    }
  }
    void previousSong() {
    if (_isDisposed || _selectedSong == null || _musicList.isEmpty) return;
    
    try {
      // Find the index of the current song
      final currentIndex = _musicList.indexWhere((song) => 
        song.name == _selectedSong!.name && song.url == _selectedSong!.url);
      
      // If found, select the previous song or loop back to the last one
      if (currentIndex != -1) {
        final previousIndex = (currentIndex - 1 + _musicList.length) % _musicList.length;
        _selectedSong = _musicList[previousIndex];
        loadAudio();
      }
      
      // Solo notificar si el objeto no ha sido eliminado
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error al cambiar a la canción anterior: $e');
    }
  }
  void setSelectedSong(RelaxingMusicModel song) {
    _selectedSong = song;
    notifyListeners();
    }
  // Load and play audio from the selected song
  Future<void> loadAudio({bool autoPlay = true}) async {
  try {
    if (_isDisposed || _loadingAudio) return;
    
    _loadingAudio = true;
    _errorMessage = '';
    
    // Solo notificar si no ha sido eliminado
    if (!_isDisposed) {
      notifyListeners();
    }
    
    if (_selectedSong == null) {
      throw Exception("No hay canción seleccionada");
    }
    
    // Check if the url is valid
    if (_selectedSong!.url.isEmpty) {
      throw Exception("URL de audio no válida");
    }
  
    // Comprobar si ha sido eliminado antes de cada operación
    if (_isDisposed) return;
    await _player.stop();

    await Future.delayed(const Duration(milliseconds: 100));
    if (_isDisposed) return;
    
    await _player.setUrl(_selectedSong!.url);

    await Future.delayed(const Duration(milliseconds: 100));
    if (_isDisposed) return;
    
    if (autoPlay) {
      await _player.play();
    }
    
    _loadingAudio = false;
    // Solo notificar si no ha sido eliminado
    if (!_isDisposed) {
      notifyListeners();
    }
    
  } catch (e) {
    if (_isDisposed) return;
    
    _errorMessage = "Error al cargar audio: $e";
    _loadingAudio = false;
    
    // Solo notificar si no ha sido eliminado
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
  // Toggle play/pause state
  Future<void> togglePlayPause() async {
    try {
      if (_player.playing) {
        await _player.pause(); 
      } else {
        await _player.play();  
      }
      // Verificar si el objeto ya fue eliminado antes de notificar
      if (!_isDisposed) {
        notifyListeners();
      }
    } catch (e) {
      print('Error al cambiar reproducción: $e');
      // No propagar el error para evitar crasheos
    }
  }// Method to cleanup resources when temporarily navigating away
  Future<void> cleanup() async {
    try {
      if (_player.playing) {
        await _player.pause();
      }
      // No llamamos a notifyListeners() para evitar actualizaciones de UI durante la navegación
    } catch (e) {
      // Ignorar errores durante la limpieza para evitar excepciones durante la navegación
      print('Error durante la limpieza del reproductor: $e');
    }
  }

  //Fetch all relaxing music
  Future<void> getMusic() async {
    _state = RelaxingMusicState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      _musicList = await _relaxingMusicService.getMeditations();
      _state = RelaxingMusicState.loaded;
    } catch (e) {
      _state = RelaxingMusicState.error;
      _errorMessage = e.toString();
    }

    notifyListeners();
  }

  /// Trigger the Magic Loops API
  Future<void> triggerMagicLoopsAPI() async {
    _state = RelaxingMusicState.loading;
    _errorMessage = '';
    notifyListeners();
    
    try {
      await _relaxingMusicService.triggerMagicLoopsAPI();
      // Opcional: si quieres cargar datos inmediatamente después
      await getMusic();
    } catch (e) {
      _state = RelaxingMusicState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Reset the state to initial
  void resetState() {
    _state = RelaxingMusicState.initial;
    _errorMessage = '';
    notifyListeners();
  }
  // Clean up resources when the ViewModel is disposed
  @override
  void dispose() {
    // Marcar como eliminado primero para evitar notificaciones adicionales
    _isDisposed = true;
    
    try {
      // Detener la reproducción de audio antes de eliminar el reproductor
      if (_player.playing) {
        _player.pause();
      }
      // Esperar un momento antes de liberar los recursos
      Future.delayed(Duration(milliseconds: 100), () {
        _player.dispose();
      });
    } catch (e) {
      print('Error durante la disposición del reproductor de audio: $e');
    }
    
    super.dispose();
  }
}