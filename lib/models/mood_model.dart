import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class AiAnalysis {
  final int sentimentScore;
  final String summary;
  final List<String> tags;
  final List<AiInsight> insights;

  AiAnalysis({
    required this.sentimentScore,
    required this.summary,
    required this.tags,
    required this.insights,
  });

  Map<String, dynamic> toJson() {
    return {
      'sentimentScore': sentimentScore,
      'summary': summary,
      'tags': tags,
      'insights': insights.map((i) => i.toJson()).toList(),
    };
  }

  factory AiAnalysis.fromJson(Map<String, dynamic> json) {
    return AiAnalysis(
      sentimentScore: json['sentimentScore'] ?? 0,
      summary: json['summary'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      insights: (json['insights'] as List?)
              ?.map((i) => AiInsight.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class AiInsight {
  final String insight;
  final String suggestion;

  AiInsight({
    required this.insight,
    required this.suggestion,
  });

  Map<String, dynamic> toJson() {
    return {
      'insight': insight,
      'suggestion': suggestion,
    };
  }

  factory AiInsight.fromJson(Map<String, dynamic> json) {
    return AiInsight(
      insight: json['insight'] ?? '',
      suggestion: json['suggestion'] ?? '',
    );
  }
}

class MoodModel {
  String label;
  String lottieAsset;
  final Color color;
  final DateTime timestamp;
  final String? note;
  final String? moodId;
  final String? content;
  final AiAnalysis? aiAnalysis;

  MoodModel({
    this.moodId,
    required this.label,
    required this.lottieAsset,
    required this.color,
    required this.timestamp,
    this.note,
    this.content,
    this.aiAnalysis,
  });

  Map<String, dynamic> toJson() {
    return {
      "moodId": moodId,
      "label": label,
      "lottieAsset": lottieAsset,
      "color": color.value,
      "timestamp": Timestamp.fromDate(timestamp),
      "note": note,
      "content": content,
      "aiAnalysis": aiAnalysis?.toJson(),
    };
  }

  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      moodId: json['moodId'] as String?,
      label: json['label'] ?? '',
      lottieAsset: json['lottieAsset'] ?? '',
      color: Color(json['color'] ?? 0xFF9E9E9E),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      note: json['note'],
      content: json['content'],
      aiAnalysis: json['aiAnalysis'] != null
          ? AiAnalysis.fromJson(json['aiAnalysis'])
          : null,
    );
  }

  MoodModel copyWith({
    String? moodId,
    String? label,
    String? lottieAsset,
    Color? color,
    DateTime? timestamp,
    String? note,
    String? content,
    AiAnalysis? aiAnalysis,
  }) {
    return MoodModel(
      moodId: moodId ?? this.moodId,
      label: label ?? this.label,
      lottieAsset: lottieAsset ?? this.lottieAsset,
      color: color ?? this.color,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      content: content ?? this.content,
      aiAnalysis: aiAnalysis ?? this.aiAnalysis,
    );
  }
}
