import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_mind/models/achievement_model.dart';
import 'package:calm_mind/models/mood_model.dart';
import 'package:calm_mind/models/chat_message.dart';
import 'package:calm_mind/repositories/achievement_repository.dart';
import 'package:calm_mind/repositories/mood_repository.dart';
import 'package:calm_mind/repositories/chat_messages_repository.dart';
import 'package:calm_mind/services/user_service.dart';

class AchievementViewModel extends ChangeNotifier {
  final AchievementRepository _achievementRepository = AchievementRepository();
  final MoodRepository _moodRepository = MoodRepository();
  final ChatMessagesRepository _chatRepository = ChatMessagesRepository();
  final UserService _userService = UserService();

  bool _isLoading = false;
  List<Achievement> _achievements = [];
  int _totalPoints = 0;

  int _currentMoodStreak = 0;
  int _totalMeditationMinutes = 0;
  int _selfCareSessionCount = 0;

  bool get isLoading => _isLoading;
  List<Achievement> get achievements => _achievements;
  int get totalPoints => _totalPoints;

  int get currentMoodStreak => _currentMoodStreak;
  int get totalMeditationMinutes => _totalMeditationMinutes;
  int get selfCareSessionCount => _selfCareSessionCount;

  AchievementViewModel() {
    _initialize();
  }

  Future<void> _initialize() async {
    await _achievementRepository.initializeUserAchievements();
    await _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _loadUserStats();
      _achievements = _getPredefinedAchievements();
      await _syncAchievementsWithUserStats();
      _calculateTotalPoints();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAchievements() async {
    await _loadAchievements();
  }

  Future<void> _loadUserStats() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final moods = await _moodRepository.getMoodHistory(userId);
    _currentMoodStreak = _calculateMoodStreak(moods);

    final userData = await _userService.getUserData(userId);
    _totalMeditationMinutes = userData?.totalMeditationMinutes ?? 0;

    await _chatRepository.getChatHistory().first.then((messages) {
      _selfCareSessionCount = _countSelfCareSessions(messages);
    }).catchError((_) {
      _selfCareSessionCount = 0;
    });
  }

  int _calculateMoodStreak(List<MoodModel> moods) {
    if (moods.isEmpty) return 0;

    moods.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    int streak = 0;
    DateTime? lastDate;
    DateTime today = DateTime.now();
    today = DateTime(today.year, today.month, today.day);

    for (final mood in moods) {
      final moodDate = DateTime(
        mood.timestamp.year,
        mood.timestamp.month,
        mood.timestamp.day,
      );

      if (lastDate == null) {
        final diffFromToday = today.difference(moodDate).inDays;
        if (diffFromToday > 1) break;
        streak = 1;
        lastDate = moodDate;
      } else {
        final diff = lastDate.difference(moodDate).inDays;
        if (diff == 1) {
          streak++;
          lastDate = moodDate;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
  }

  int _countSelfCareSessions(List<ChatMessage> messages) {
    final sessionIds = <String>{};
    for (final message in messages) {
      sessionIds.add(message.sessionId);
    }
    return sessionIds.length;
  }

  Future<void> _syncAchievementsWithUserStats() async {
    final unlockedIds = await _achievementRepository.getUnlockedAchievementIds();

    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      final shouldBeUnlocked = _shouldUnlock(achievement);

      if (shouldBeUnlocked && !unlockedIds.contains(achievement.id)) {
        await _achievementRepository.unlockAchievement(achievement.id);
        unlockedIds.add(achievement.id);
      }

      _achievements[i] = Achievement(
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        iconAsset: achievement.iconAsset,
        points: achievement.points,
        type: achievement.type,
        level: achievement.level,
        requirement: achievement.requirement,
        isUnlocked: unlockedIds.contains(achievement.id),
        unlockedAt: unlockedIds.contains(achievement.id)
            ? await _achievementRepository.getUnlockedDate(achievement.id)
            : null,
      );
    }
  }

  bool _shouldUnlock(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.MOOD_STREAK:
        return _currentMoodStreak >= achievement.requirement;
      case AchievementType.MEDITATION_TIME:
        return _totalMeditationMinutes >= achievement.requirement;
      case AchievementType.SELF_CARE:
        return _selfCareSessionCount >= achievement.requirement;
    }
  }

  int getAchievementProgress(Achievement achievement) {
    switch (achievement.type) {
      case AchievementType.MOOD_STREAK:
        return _currentMoodStreak;
      case AchievementType.MEDITATION_TIME:
        return _totalMeditationMinutes;
      case AchievementType.SELF_CARE:
        return _selfCareSessionCount;
    }
  }

  void _calculateTotalPoints() {
    _totalPoints = _achievements
        .where((achievement) => achievement.isUnlocked)
        .fold(0, (sum, achievement) => sum + achievement.points);
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  List<String> getUnlockedBadges() {
    return _achievements
        .where((ach) => ach.isUnlocked)
        .map((ach) => ach.iconAsset)
        .toList();
  }

  List<Achievement> _getPredefinedAchievements() {
    return [
      Achievement(
        id: 'mood_streak_3',
        title: 'Primeros Pasos',
        description: 'Registra tu estado de ánimo por 3 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_1.png',
        points: 50,
        type: AchievementType.MOOD_STREAK,
        level: 'BRONZE',
        requirement: 3,
      ),
      Achievement(
        id: 'mood_streak_7',
        title: 'Constancia Emocional',
        description: 'Registra tu estado de ánimo por 7 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_2.png',
        points: 100,
        type: AchievementType.MOOD_STREAK,
        level: 'SILVER',
        requirement: 7,
      ),
      Achievement(
        id: 'mood_streak_30',
        title: 'Maestro del Bienestar',
        description: 'Registra tu estado de ánimo por 30 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_3.png',
        points: 250,
        type: AchievementType.MOOD_STREAK,
        level: 'GOLD',
        requirement: 30,
      ),
      Achievement(
        id: 'mood_streak_100',
        title: 'Leyenda del Ánimo',
        description: 'Registra tu estado de ánimo por 100 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_4.png',
        points: 500,
        type: AchievementType.MOOD_STREAK,
        level: 'DIAMOND',
        requirement: 100,
      ),
      Achievement(
        id: 'meditation_60',
        title: 'Principiante Zen',
        description: 'Acumula 1 hora de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_1.png',
        points: 40,
        type: AchievementType.MEDITATION_TIME,
        level: 'BRONZE',
        requirement: 60,
      ),
      Achievement(
        id: 'meditation_300',
        title: 'Meditador Intermedio',
        description: 'Acumula 5 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_2.png',
        points: 80,
        type: AchievementType.MEDITATION_TIME,
        level: 'SILVER',
        requirement: 300,
      ),
      Achievement(
        id: 'meditation_600',
        title: 'Experto en Calma',
        description: 'Acumula 10 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_3.png',
        points: 150,
        type: AchievementType.MEDITATION_TIME,
        level: 'GOLD',
        requirement: 600,
      ),
      Achievement(
        id: 'meditation_1200',
        title: 'Gran Maestro Zen',
        description: 'Acumula 20 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_4.png',
        points: 300,
        type: AchievementType.MEDITATION_TIME,
        level: 'DIAMOND',
        requirement: 1200,
      ),
      Achievement(
        id: 'self_care_1',
        title: 'Primer Autocuidado',
        description: 'Ten al menos una sesión de autocuidado con Numa',
        iconAsset: 'assets/images/achievements/self-care_1.png',
        level: 'BRONZE',
        points: 50,
        requirement: 1,
        type: AchievementType.SELF_CARE,
      ),
      Achievement(
        id: 'self_care_5',
        title: 'Amigo de Numa',
        description: 'Ten al menos cinco sesiones de autocuidado con Numa',
        iconAsset: 'assets/images/achievements/self-care_2.png',
        level: 'SILVER',
        points: 100,
        requirement: 5,
        type: AchievementType.SELF_CARE,
      ),
      Achievement(
        id: 'self_care_15',
        title: 'Confidente de Numa',
        description: 'Ten al menos 15 sesiones de autocuidado con Numa',
        iconAsset: 'assets/images/achievements/self-care_3.png',
        level: 'GOLD',
        points: 200,
        requirement: 15,
        type: AchievementType.SELF_CARE,
      ),
      Achievement(
        id: 'self_care_30',
        title: 'Maestro del Autocuidado',
        description: 'Ten al menos 30 sesiones de autocuidado con Numa',
        iconAsset: 'assets/images/achievements/self-care_4.png',
        level: 'DIAMOND',
        points: 400,
        requirement: 30,
        type: AchievementType.SELF_CARE,
      ),
    ];
  }
}