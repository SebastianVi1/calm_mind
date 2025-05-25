import 'package:flutter/foundation.dart';
import '../models/achievement_model.dart';

class AchievementViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Achievement> _achievements = [];
  int _totalPoints = 0;

  bool get isLoading => _isLoading;
  List<Achievement> get achievements => _achievements;
  int get totalPoints => _totalPoints;

  AchievementViewModel() {
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    _isLoading = true;
    notifyListeners();

    try {
      // TODO: make the repository for the achievements
      _achievements = _getPredefinedAchievements();
      _calculateTotalPoints();
    } catch (e) {
      debugPrint('Error loading achievements: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
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
  List<String> getUnlockedBadges (){
    List<String> unlockedBadges = [];
    for (Achievement ach in _getPredefinedAchievements()){
      if (ach.isUnlocked){
        unlockedBadges.add(ach.iconAsset);
      }
    }
    return unlockedBadges;
  }
  List<Achievement> _getPredefinedAchievements() {
    return [
      // Logros de Estado de Ánimo
      Achievement(
        id: 'mood_streak_3',
        title: 'Primeros Pasos',
        description: 'Registra tu estado de ánimo por 3 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_1.png',
        points: 50,
        type: AchievementType.MOOD_STREAK,
        level: 'BRONZE',
        requirement: 3,
        isUnlocked: true,
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
        isUnlocked: true,
      ),
      
      Achievement(
        id: 'mood_streak_30',
        title: 'Constancia Emocional',
        description: 'Registra tu estado de ánimo por 30 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_3.png',
        points: 100,
        type: AchievementType.MOOD_STREAK,
        level: 'GOLD',
        requirement: 7,
      ),
      Achievement(
        id: 'mood_streak_100',
        title: 'Constancia Emocional',
        description: 'Registra tu estado de ánimo por 100 días consecutivos',
        iconAsset: 'assets/images/achievements/trofeo_4.png',
        points: 100,
        type: AchievementType.MOOD_STREAK,
        level: 'DIAMOND',
        requirement: 7,
      ),
      // Meditation achievements
      Achievement(
        id: 'meditation_1h',
        title: 'Principiante Zen',
        description: 'Acumula 1 hora de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_1.png',
        points: 40,
        type: AchievementType.MEDITATION_TIME,
        level: 'BRONZE',
        requirement: 60,
        isUnlocked: true,
      ),
      Achievement(
        id: 'meditation_5h',
        title: 'Meditador Intermedio',
        description: 'Acumula 5 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_2.png',
        points: 80,
        type: AchievementType.MEDITATION_TIME,
        level: 'SILVER',
        requirement: 300,      
      ),
      Achievement(
        id: 'meditation_10h',
        title: 'Meditador Intermedio',
        description: 'Acumula 10 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_3.png',
        points: 80,
        type: AchievementType.MEDITATION_TIME,
        level: 'GOLD',
        requirement: 300,
      ),
      Achievement(
        id: 'meditation_20h',
        title: 'Meditador Intermedio',
        description: 'Acumula 20 horas de meditación',
        iconAsset: 'assets/images/achievements/meditation_badge_4.png',
        points: 80,
        type: AchievementType.MEDITATION_TIME,
        level: 'DIAMOND',
        requirement: 300,
      ),
        
      Achievement(
        id: 'self-care_1h',
        title: 'Autocuidado 1',
        description: 'Ten almenos una sesion de autocuidado con numa',
        iconAsset: 'assets/images/achievements/self-care_1.png',
        level: 'COPPPER',
        points: 50,
        requirement: 400,
        type: AchievementType.SELF_CARE,
        isUnlocked: true,
      ),
      Achievement(
        id: 'self-care_1h',
        title: 'Autocuidado 1',
        description: 'Ten almenos cinco sesiones de autocuidado con numa',
        iconAsset: 'assets/images/achievements/self-care_2.png',
        level: 'SILVER',
        points: 50,
        requirement: 400,
        type: AchievementType.SELF_CARE,
        isUnlocked: true,
      ),
      Achievement(
        id: 'self-care_1h',
        title: 'Autocuidado 1',
        description: 'Ten almenos 15 sesiones de autocuidado con numa',
        iconAsset: 'assets/images/achievements/self-care_3.png',
        level: 'GOLD',
        points: 50,
        requirement: 400,
        type: AchievementType.SELF_CARE,
        isUnlocked: true,
      ),
      Achievement(
        id: 'self-care_1h',
        title: 'Autocuidado 1',
        description: 'Ten almenos 30 de autocuidado con numa',
        iconAsset: 'assets/images/achievements/self-care_4.png',
        level: 'DIAMOND',
        points: 50,
        requirement: 400,
        type: AchievementType.SELF_CARE,
        isUnlocked: false,
      ),
      
    ];
  }
} 