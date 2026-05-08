enum CopingStrategyType {
  BREATHING,
  GROUNDING,
  COGNITIVE_REFRAMING,
  PROGRESSIVE_RELAXATION,
  MINDFULNESS,
  PHYSICAL,
  CREATIVE,
  SOCIAL,
}

class CopingStrategy {
  final String id;
  final String title;
  final String description;
  final CopingStrategyType type;
  final String icon;
  final int durationMinutes;
  final List<String> steps;
  final List<String> forMoods;
  final String? audioUrl;

  CopingStrategy({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.icon,
    required this.durationMinutes,
    required this.steps,
    required this.forMoods,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'type': type.toString(),
      'icon': icon,
      'durationMinutes': durationMinutes,
      'steps': steps,
      'forMoods': forMoods,
      'audioUrl': audioUrl,
    };
  }

  factory CopingStrategy.fromJson(Map<String, dynamic> json) {
    return CopingStrategy(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      type: CopingStrategyType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => CopingStrategyType.MINDFULNESS,
      ),
      icon: json['icon'],
      durationMinutes: json['durationMinutes'],
      steps: List<String>.from(json['steps']),
      forMoods: List<String>.from(json['forMoods']),
      audioUrl: json['audioUrl'],
    );
  }
}

class CopingSession {
  final String strategyId;
  final DateTime timestamp;
  final int completedSteps;
  final int totalSteps;
  final String? moodBefore;
  final String? moodAfter;

  CopingSession({
    required this.strategyId,
    required this.timestamp,
    required this.completedSteps,
    required this.totalSteps,
    this.moodBefore,
    this.moodAfter,
  });

  bool get isCompleted => completedSteps >= totalSteps;

  Map<String, dynamic> toJson() {
    return {
      'strategyId': strategyId,
      'timestamp': timestamp.toIso8601String(),
      'completedSteps': completedSteps,
      'totalSteps': totalSteps,
      'moodBefore': moodBefore,
      'moodAfter': moodAfter,
    };
  }

  factory CopingSession.fromJson(Map<String, dynamic> json) {
    return CopingSession(
      strategyId: json['strategyId'],
      timestamp: DateTime.parse(json['timestamp']),
      completedSteps: json['completedSteps'],
      totalSteps: json['totalSteps'],
      moodBefore: json['moodBefore'],
      moodAfter: json['moodAfter'],
    );
  }
}
