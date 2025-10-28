import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:calm_mind/models/meditation_audio_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;


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


  // Track initialization state
  bool _isInitialized = false;
  
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

      // Initialize: set up first audio source and prefetch all tracks for offline
      await loadAudio();
      // Start background prefetch for the whole list so they are ready offline
      _prefetchMeditationCaches();
      
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
      
      // Stop current playback before switching
      if (_audioPlayer.playing) {
        await _audioPlayer.stop();
      }

      final url = _selectedMeditation!.url;
      final file = await _getCachedFileForUrl(url);

      if (await file.exists()) {
        // Play from cache
        await _audioPlayer.setFilePath(file.path);
      } else {
        // Try to download and cache, then play
        try {
          await _downloadToFile(url, file);
          if (await file.exists()) {
            await _audioPlayer.setFilePath(file.path);
          } else {
            await _audioPlayer.setUrl(url);
          }
        } catch (_) {
          // Fallback to streaming if download fails
          await _audioPlayer.setUrl(url);
        }
      }

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
  
  
  void nextMeditation() {
    if (_selectedMeditation == null || urls.isEmpty) return;
    
    // Find the index of the current meditation
    final currentIndex = urls.indexWhere((meditation) => 
      meditation.title == _selectedMeditation!.title && meditation.url == _selectedMeditation!.url);
    
    // If found, select the next meditation or loop back to the first one
    if (currentIndex != -1) {
      final nextIndex = (currentIndex + 1) % urls.length;
      _selectedMeditation = urls[nextIndex];
      loadAudio();
    }
    
    notifyListeners();
  }
  
  
  void previousMeditation() {
    if (_selectedMeditation == null || urls.isEmpty) return;
    
    // Find the index of the current meditation
    final currentIndex = urls.indexWhere((meditation) => 
      meditation.title == _selectedMeditation!.title && meditation.url == _selectedMeditation!.url);
    
    // If found, select the previous meditation or loop back to the last one
    if (currentIndex != -1) {
      final previousIndex = (currentIndex - 1 + urls.length) % urls.length;
      _selectedMeditation = urls[previousIndex];
      loadAudio();
    }
    
    notifyListeners();
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
    }
  @override
  void dispose() {
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  // ---------- Simple file cache helpers ----------
  Future<Directory> _getCacheDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory('${base.path}${Platform.pathSeparator}meditations_cache');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String _fileNameForUrl(String url) {
    // Very simple stable filename based on URL hash
    // Avoid special characters and keep a consistent extension
    final safe = url.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final truncated = safe.length > 80 ? safe.substring(0, 80) : safe;
    return 'med_$truncated.mp3';
  }

  Future<File> _getCachedFileForUrl(String url) async {
    final dir = await _getCacheDir();
    final name = _fileNameForUrl(url);
    return File('${dir.path}${Platform.pathSeparator}$name');
  }

  Future<void> _downloadToFile(String url, File file) async {
    final resp = await http.get(Uri.parse(url));
    if (resp.statusCode == 200) {
      await file.writeAsBytes(resp.bodyBytes, flush: true);
    } else {
      throw Exception('Download failed: ${resp.statusCode}');
    }
  }

  // Prefetch all meditation audios on entering the list/screen
  void _prefetchMeditationCaches() async {
    // Download sequentially to avoid spikes; ignore errors
    for (final m in urls) {
      try {
        final f = await _getCachedFileForUrl(m.url);
        if (!await f.exists()) {
          await _downloadToFile(m.url, f);
        }
      } catch (_) {
        // Ignore prefetch errors; playback will fallback to URL
      }
    }
  }
}
