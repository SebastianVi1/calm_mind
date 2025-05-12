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
      _position = p;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      _loadingAudio = false;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
     
      
      if (state.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _player.pause();
        _player.seek(_position);

        notifyListeners();
      }
    });    // Listen for errors
    _player.playbackEventStream.listen((event) {}, 
      onError: (Object e, StackTrace stackTrace) {
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
  }

   void handleSeek(double value) {
    _player.seek(Duration(seconds: value.toInt()));
  }  void nextSong(){
    if (_selectedSong == null || _musicList.isEmpty) return;
    
    // Find the index of the current song
    final currentIndex = _musicList.indexWhere((song) => 
      song.name == _selectedSong!.name && song.url == _selectedSong!.url);
    
    // If found, select the next song or loop back to the first one
    if (currentIndex != -1) {
      final nextIndex = (currentIndex + 1) % _musicList.length;
      _selectedSong = _musicList[nextIndex];
      loadAudio();
    }
    
    notifyListeners();
  }
  
  void previousSong(){
    if (_selectedSong == null || _musicList.isEmpty) return;
    
    // Find the index of the current song
    final currentIndex = _musicList.indexWhere((song) => 
      song.name == _selectedSong!.name && song.url == _selectedSong!.url);
    
    // If found, select the previous song or loop back to the last one
    if (currentIndex != -1) {
      final previousIndex = (currentIndex - 1 + _musicList.length) % _musicList.length;
      _selectedSong = _musicList[previousIndex];
      loadAudio();
    }
    
    notifyListeners();
  }
  void setSelectedSong(RelaxingMusicModel song) {
    _selectedSong = song;
    notifyListeners();
    }

  // Load and play audio from the selected song
  Future<void> loadAudio({bool autoPlay = true}) async {
  try {
    if (_loadingAudio) return;
    
    _loadingAudio = true;
    _errorMessage = '';
    notifyListeners();
    
    
    if (_selectedSong == null) {
      throw Exception("No hay canción seleccionada");
    }
    
    // Check if the url is valid
    if (_selectedSong!.url.isEmpty) {
      throw Exception("URL de audio no válida");
    }
  

    await _player.stop();

    await Future.delayed(const Duration(milliseconds: 100));

    await _player.setUrl(_selectedSong!.url);

    await Future.delayed(const Duration(milliseconds: 100));

    if (autoPlay) {
      await _player.play();

    }
    
    _loadingAudio = false;
    notifyListeners();
    
  } catch (e) {
    _errorMessage = "Error al cargar audio: $e";
    _loadingAudio = false;
    notifyListeners();
  }
}

  // Toggle play/pause state
  Future<void> togglePlayPause() async {
    if (_player.playing) {
      await _player.pause(); // CORRECCIÓN: Pausa cuando está reproduciendo
    } else {
      await _player.play();  // Reproduce cuando está pausado
    }
    notifyListeners();
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
    _isDisposed = true;
    _player.dispose();
    super.dispose();
  }
}