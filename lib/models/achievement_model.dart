enum AchievementType {
  MOOD_STREAK,
  MEDITATION_TIME,
  SELF_CARE,
}

class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final int points;
  final AchievementType type;
  final String level;
  final int requirement;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.points,
    required this.type,
    required this.level,
    required this.requirement,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'points': points,
      'type': type.toString(),
      'level': level,
      'requirement': requirement,
      'isUnlocked': isUnlocked,
      'unlockedAt': unlockedAt?.toIso8601String(),
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      iconAsset: json['iconAsset'],
      points: json['points'],
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      level: json['level'],
      requirement: json['requirement'],
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'])
          : null,
    );
  }
} 