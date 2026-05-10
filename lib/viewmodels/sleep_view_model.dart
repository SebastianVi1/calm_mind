import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import '../models/sleep_content_model.dart';
import '../services/sleep_content_generator.dart';

class SleepViewModel extends ChangeNotifier {
  final SleepContentGenerator _generator;
  late AudioPlayer _player;

  List<SleepContentModel> _ambientSounds = [];
  List<SleepContentModel> _sleepStories = [];
  bool _isLoading = false;

  List<SleepContentModel> get ambientSounds => _ambientSounds;
  List<SleepContentModel> get sleepStories => _sleepStories;
  bool get isLoading => _isLoading;

  SleepContentModel? _selectedContent;
  SleepContentModel? get selectedContent => _selectedContent;

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  bool _isGenerating = false;
  bool get isGenerating => _isGenerating;

  bool _loadingAudio = false;
  bool get loadingAudio => _loadingAudio;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Duration _position = Duration.zero;
  Duration get position => _position;

  Duration _duration = Duration.zero;
  Duration get duration => _duration;

  int _timerMinutes = 30;
  int get timerMinutes => _timerMinutes;
  int _remainingSeconds = 0;
  int get remainingSeconds => _remainingSeconds;
  Timer? _sleepTimer;
  Timer? get sleepTimer => _sleepTimer;
  double _volume = 0.7;
  double get volume => _volume;

  bool _timerActive = false;
  bool get timerActive => _timerActive;

  SleepViewModel(this._generator) {
    _player = AudioPlayer();
    _initializePlayerListeners();
    loadContent();
  }

  void _initializePlayerListeners() {
    _player.positionStream.listen((p) {
      _position = p;
      notifyListeners();
    });

    _player.durationStream.listen((d) {
      _duration = d ?? Duration.zero;
      notifyListeners();
    });

    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _position = Duration.zero;
        _isPlaying = false;
        _player.pause();
        _player.seek(Duration.zero);
        notifyListeners();
      }
    });

    _player.playbackEventStream.listen(
      (_) {},
      onError: (e, stack) {
        _errorMessage = 'Error de reproducción: $e';
        _loadingAudio = false;
        notifyListeners();
      },
    );
  }

  void loadContent() {
    _isLoading = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 400), () {
      _ambientSounds = SleepContentModel.ambientSounds();
      _sleepStories = SleepContentModel.sleepStories();
      _isLoading = false;
      notifyListeners();
    });
  }

  void selectContent(SleepContentModel content) {
    _selectedContent = content;
    _isPlaying = false;
    _cancelTimer();
    notifyListeners();
  }

  List<SleepContentModel> get _allContent => [..._ambientSounds, ..._sleepStories];

  Future<void> generateAndPlay(SleepContentModel content) async {
    _selectedContent = content;
    _errorMessage = null;
    notifyListeners();

    try {
      final cached = await _generator.isCached(content.id);

      File audioFile;
      if (cached) {
        audioFile = await _generator.getCachedFile(content.id);
      } else {
        _isGenerating = true;
        notifyListeners();

        if (content.type == SleepContentType.ambient) {
          audioFile = await _generator.generateAmbientAudio(content);
        } else {
          audioFile = await _generator.generateStoryAudio(content);
        }

        _isGenerating = false;
        _loadingAudio = true;
        notifyListeners();
      }

      if (_player.playing) {
        await _player.stop();
      }

      await _player.setFilePath(audioFile.path);
      await _player.setVolume(_volume);
      await _player.setLoopMode(
        content.isLoopable ? LoopMode.one : LoopMode.off,
      );

      await _player.play();
      _isPlaying = true;
      _loadingAudio = false;
      notifyListeners();
    } catch (e) {
      _isGenerating = false;
      _loadingAudio = false;
      _errorMessage = 'Error: $e';
      notifyListeners();
    }
  }

  void handlePlayPause() {
    if (_player.playing) {
      _player.pause();
      _isPlaying = false;
    } else {
      _player.play();
      _isPlaying = true;
    }
    notifyListeners();
  }

  void handleSeek(double value) {
    _player.seek(Duration(seconds: value.toInt()));
  }

  void setVolume(double v) {
    _volume = v.clamp(0.0, 1.0);
    _player.setVolume(_volume);
    notifyListeners();
  }

  void playNext() {
    if (_selectedContent == null || _allContent.isEmpty) return;

    final currentIndex = _allContent.indexWhere(
      (c) => c.id == _selectedContent!.id,
    );
    if (currentIndex == -1) return;

    final nextIndex = (currentIndex + 1) % _allContent.length;
    generateAndPlay(_allContent[nextIndex]);
  }

  void playPrevious() {
    if (_selectedContent == null || _allContent.isEmpty) return;

    final currentIndex = _allContent.indexWhere(
      (c) => c.id == _selectedContent!.id,
    );
    if (currentIndex == -1) return;

    final prevIndex =
        (currentIndex - 1 + _allContent.length) % _allContent.length;
    generateAndPlay(_allContent[prevIndex]);
  }

  void setTimerMinutes(int minutes) {
    _timerMinutes = minutes;
    notifyListeners();
  }

  void startSleepTimer() {
    _cancelTimer();
    _remainingSeconds = _timerMinutes * 60;
    _timerActive = true;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 0) {
        _cancelTimer();
        _player.pause();
        _isPlaying = false;
        notifyListeners();
        return;
      }
      _remainingSeconds--;
      notifyListeners();
    });
  }

  void _cancelTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    _timerActive = false;
    _remainingSeconds = 0;
  }

  Future<void> regenerateAll() async {
    await _generator.clearAllCache();
    _errorMessage = null;
    _isPlaying = false;
    _isGenerating = false;
    _loadingAudio = false;
    notifyListeners();
    if (_selectedContent != null) {
      await generateAndPlay(_selectedContent!);
    }
  }

  String get formattedTime {
    final min = _remainingSeconds ~/ 60;
    final sec = _remainingSeconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  String formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void togglePlayback() {
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  @override
  void dispose() {
    _cancelTimer();
    _player.stop();
    _player.dispose();
    super.dispose();
  }
}
