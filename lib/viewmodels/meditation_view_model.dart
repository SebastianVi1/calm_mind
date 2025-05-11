import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:re_mind/models/meditation_audio_model.dart';
import 'package:video_player/video_player.dart';

/// ViewModel for the meditation screen that handles the audio and video resources.
/// Manages the playback state, loading, and error handling for meditation sessions.
class MeditationViewModel extends ChangeNotifier {
  // Audio player properties and state
  late AudioPlayer _audioPlayer;
  bool _loadingAudio = true;
  bool get loadingAudio => _loadingAudio;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  Duration _position = Duration.zero;
  Duration get position => _position;
  Duration _duration = Duration.zero;
  Duration get duration => _duration;
  bool get isPlaying => _audioPlayer.playing;
    // Video player
  late VideoPlayerController _videoController;
  bool loadingVideo = false;
  VideoPlayerController get videoController => _videoController;
  bool _videoInitialized = false;
  bool get videoInitialized => _videoInitialized;
  
  // Track initialization state
  bool _isInitialized = false;
  // Track disposal state
  bool _isDisposed = false;
  
  // Constructor initializes the audio player and sets up listeners
  MeditationViewModel() {
    _audioPlayer = AudioPlayer();
    _initializeAudioListeners();
  }


  MeditationAudioModel? _selectedMeditation;
  MeditationAudioModel? get selectedMeditation => _selectedMeditation;
  void setSelectedMeditation(MeditationAudioModel meditation){
    _selectedMeditation = meditation;
    notifyListeners();
  }

  List<MeditationAudioModel> urls = [
    MeditationAudioModel(
      url: 'https://cultivarlamente.com/wp-content/uploads/2020/06/gonzalo-brito-pausa-consciente-de-5-minutos.mp3',
      duration: '5-MIN',
      title: 'Pausa consciente de 5 minutos'
    ),
    MeditationAudioModel(
      url: 'https://cultivarlamente.com/wp-content/uploads/2016/06/Atenci%C3%B3n-plena-a-la-respiraci%C3%B3n-de-10-minutos.mp3',
      title: 'Atencion plena a la respiracion',
      duration: '10-MIN'
    ),
    MeditationAudioModel(
      url: 'https://cultivarlamente.com/wp-content/uploads/2017/12/Yo-Compasivo-Corta-12-Minutos.mp3',
      duration: '12_MIN',
      title: 'Practica del yo compasivo'
    ),
    MeditationAudioModel(
      url: 'https://cultivarlamente.com/wp-content/uploads/2020/12/Espalda-fuerte-Corazon-Suave.mp3',
      title: 'Espalda fuerte corazon suave',
      duration: '18_MIN'
    ),
  ];
  /// Initializes both audio and video resources
  /// Prevents multiple initializations by checking state
  Future<void> initializeResources() async {
    // Avoid multiple initializations
    if (_isInitialized) {
      _resetState();
    }
    
    try {
      _loadingAudio = true;
      _errorMessage = null;
      notifyListeners();

      // Initialize both video and audio in parallel
      await Future.wait([
        _initializeVideo(), // Make sure to initialize video
        loadAudio(),
      ]);
      
      // All resources loaded successfully
      _loadingAudio = false;
      _isInitialized = true;
      notifyListeners();
    } catch (e) {      _errorMessage = "Error loading resources: $e";
      _loadingAudio = false;
      notifyListeners();
    }
  }
    // Reset state when re-initializing
  void _resetState() {
    // Stop active playback
    if (_audioPlayer.playing) {
      _audioPlayer.stop();
    }
    
    _position = Duration.zero;
    _duration = Duration.zero;
    notifyListeners();
  }
  Future<void> _initializeVideo() async {
    loadingVideo = true;
    notifyListeners();
    
    // If a controller is already initialized, release it
    if (_videoInitialized) {
      await _videoController.dispose();
      _videoInitialized = false;
    }
    
    // Use local asset
    _videoController = VideoPlayerController.asset('assets/video/background_meditation.mp4');
    
    try {
      await _videoController.initialize();
      _videoInitialized = true;
      _videoController.setLooping(true);
      _videoController.setPlaybackSpeed(0.25);
      _videoController.setVolume(0.0);
      _videoController.play();
      loadingVideo = false;
      notifyListeners();
    } catch (error) {      print("Error initializing video: $error");
      _errorMessage = "Error loading video: $error";
      loadingVideo = false;
      notifyListeners();
      throw error;
    }
  }

  void _initializeAudioListeners() {
    _audioPlayer.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      _loadingAudio = false;
      notifyListeners();
    });

    _audioPlayer.playerStateStream.listen((state) {
     
      
      if (state.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _audioPlayer.pause();
        _audioPlayer.seek(_position);

        notifyListeners();
      }
    });    // Listen for errors
    _audioPlayer.playbackEventStream.listen((event) {}, 
      onError: (Object e, StackTrace stackTrace) {
        _errorMessage = "Error de reproduccion: $e";
        _loadingAudio = false;
        notifyListeners();
      }
    );
  }
  Future<void> loadAudio() async {
    try {
      _loadingAudio = true;
      _errorMessage = null;
      notifyListeners();
      
      // Check if a meditation is selected, use default if not
      if (_selectedMeditation == null) {
        // Use the first meditation as a fallback
        _selectedMeditation = urls.isNotEmpty ? urls[0] : null;
        
        if (_selectedMeditation == null) {
          throw Exception("No meditation tracks available");
        }
      }
      
      await _audioPlayer.setUrl(_selectedMeditation!.url);
      await _audioPlayer.setVolume(1.0);

      _loadingAudio = false;
      notifyListeners();
      
    } catch (e) {      _errorMessage = "Error loading audio: $e";
      _loadingAudio = false;
      notifyListeners();
    }
  }

  void handlePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
      
    }
    notifyListeners();
  }

  void handleSeek(double value) {
    _audioPlayer.seek(Duration(seconds: value.toInt()));
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2,'0')}";
  }  // To clean up resources when temporarily navigating away from the screen
  void cleanup() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    }
    if (_videoInitialized && _videoController.value.isPlaying) {
      _videoController.pause();
    }
  }
  @override
  void dispose() {
    _isDisposed = true; // Mark as disposed to prevent operations on disposed objects
    _audioPlayer.stop();
    _audioPlayer.dispose();
    if (_videoInitialized) {
      _videoController.dispose();
    }
    super.dispose();
  }
}