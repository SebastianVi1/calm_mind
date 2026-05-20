import 'dart:math';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/material.dart';

enum AudioType { music, meditation, sleep }

class CalmMindAudioHandler extends BaseAudioHandler with SeekHandler {
  final AudioPlayer _player;
  final AudioType _audioType;
  final String _title;
  final String _artist;

  CalmMindAudioHandler({
    required AudioPlayer player,
    required AudioType audioType,
    required String title,
    String artist = 'CalmMind',
  })  : _player = player,
        _audioType = audioType,
        _title = title,
        _artist = artist {
    _init();
  }

  void _init() {
    _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
  }

  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      },
      androidCompactActionIndices: const [0, 1, 3],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[_player.processingState]!,
      playing: _player.playing,
      updatePosition: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
      queueIndex: 0,
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToNext() async {
    // Will be handled by the viewmodel
  }

  @override
  Future<void> skipToPrevious() async {
    // Will be handled by the viewmodel
  }

  Future<void> setTitle(String title) {
    // For updating UI title dynamically
  }
}

class AudioNotificationService {
  static final AudioNotificationService _instance = AudioNotificationService._internal();
  factory AudioNotificationService() => _instance;
  AudioNotificationService._internal();

  CalmMindAudioHandler? _currentHandler;
  AudioPlayer? _currentPlayer;
  AudioType? _currentType;
  String? _currentTitle;

  CalmMindAudioHandler? get currentHandler => _currentHandler;
  bool get hasActiveHandler => _currentHandler != null;

  String _getNotificationChannelId() {
    switch (_currentType) {
      case AudioType.music:
        return 'calm_mind_music';
      case AudioType.meditation:
        return 'calm_mind_meditation';
      case AudioType.sleep:
        return 'calm_mind_sleep';
      default:
        return 'calm_mind_audio';
    }
  }

  String _getNotificationChannelName() {
    switch (_currentType) {
      case AudioType.music:
        return 'Music Playback';
      case AudioType.meditation:
        return 'Meditation';
      case AudioType.sleep:
        return 'Sleep Sounds';
      default:
        return 'Audio Playback';
    }
  }

  String _getNotificationChannelDescription() {
    switch (_currentType) {
      case AudioType.music:
        return 'Controls for relaxing music playback';
      case AudioType.meditation:
        return 'Controls for meditation audio';
      case AudioType.sleep:
        return 'Controls for sleep sounds';
      default:
        return 'Audio playback controls';
    }
  }

  Future<CalmMindAudioHandler> initAudioHandler({
    required AudioPlayer player,
    required AudioType audioType,
    required String title,
    String artist = 'CalmMind',
  }) async {
    _currentPlayer = player;
    _currentType = audioType;
    _currentTitle = title;

    final handler = await AudioService.init(
      builder: () => CalmMindAudioHandler(
        player: player,
        audioType: audioType,
        title: title,
        artist: artist,
      ),
      config: AndroidConfiguration(
        onNotificationCreated: (controls, every) {
          return;
        },
        onNotificationUpdate: (controls) {
          return;
        },
        onNotificationClosed: (controller) async {
          await player.stop();
        },
        onClick: (controls) async {
          if (controls.contains(MediaControl.play)) {
            await player.play();
          } else if (controls.contains(MediaControl.pause)) {
            await player.pause();
          }
        },
        androidNotificationChannelId: _getNotificationChannelId(),
        androidNotificationChannelName: _getNotificationChannelName(),
        androidNotificationChannelDescription: _getNotificationChannelDescription(),
        androidNotificationOngoing: true,
        androidStopForegroundOnPause: true,
      ),
    );

    _currentHandler = handler;
    return handler;
  }

  Future<void> updatePlaybackState({
    required bool isPlaying,
    Duration position = Duration.zero,
    Duration? duration,
  }) async {
    if (_currentHandler == null || _currentPlayer == null) return;

    if (isPlaying) {
      await _currentHandler!.play();
    } else {
      await _currentHandler!.pause();
    }
  }

  Future<void> updateMediaTitle(String title) async {
    if (_currentHandler == null || _currentPlayer == null) return;

    _currentTitle = title;
    await _currentHandler!.setTitle(title);
  }

  Future<void> stopAndClear() async {
    if (_currentHandler != null) {
      await _currentHandler!.stop();
      _currentHandler = null;
    }
    _currentPlayer = null;
    _currentType = null;
    _currentTitle = null;
  }

  Future<void> seekTo(Duration position) async {
    if (_currentHandler == null || _currentPlayer == null) return;
    await _currentHandler!.seek(position);
  }
}