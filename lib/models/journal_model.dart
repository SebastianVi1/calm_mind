enum CognitiveDistortionType {
  CATASTROPHIZING,
  BLACK_AND_WHITE_THINKING,
  OVERGENERALIZATION,
  MIND_READING,
  PERSONALIZATION,
  EMOTIONAL_REASONING,
  SHOULD_STATEMENTS,
  LABELING,
  NONE,
}

class JournalInsight {
  final String insight;
  final CognitiveDistortionType distortionType;
  final String suggestion;

  JournalInsight({
    required this.insight,
    required this.distortionType,
    required this.suggestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'insight': insight,
      'distortionType': distortionType.toString(),
      'suggestion': suggestion,
    };
  }

  factory JournalInsight.fromJson(Map<String, dynamic> json) {
    return JournalInsight(
      insight: json['insight'],
      distortionType: CognitiveDistortionType.values.firstWhere(
        (e) => e.toString() == json['distortionType'],
        orElse: () => CognitiveDistortionType.NONE,
      ),
      suggestion: json['suggestion'],
    );
  }
}

class JournalEntry {
  final String id;
  final String content;
  final DateTime timestamp;
  final String? moodLabel;
  final String? aiAnalysis;
  final List<JournalInsight> insights;
  final List<String> tags;
  final int? sentimentScore;

  JournalEntry({
    required this.id,
    required this.content,
    required this.timestamp,
    this.moodLabel,
    this.aiAnalysis,
    this.insights = const [],
    this.tags = const [],
    this.sentimentScore,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'moodLabel': moodLabel,
      'aiAnalysis': aiAnalysis,
      'insights': insights.map((i) => i.toJson()).toList(),
      'tags': tags,
      'sentimentScore': sentimentScore,
    };
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'],
      content: json['content'],
      timestamp: DateTime.parse(json['timestamp']),
      moodLabel: json['moodLabel'],
      aiAnalysis: json['aiAnalysis'],
      insights: (json['insights'] as List<dynamic>?)
              ?.map((i) => JournalInsight.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      sentimentScore: json['sentimentScore'],
    );
  }
}
