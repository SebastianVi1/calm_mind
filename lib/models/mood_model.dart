import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class MoodModel{
  String label;
  String lottieAsset;
  final Color color;
  final DateTime timestamp;
  final String? note;
  final String? moodId;
  MoodModel({
    this.moodId,
    required this.label,
    required this.lottieAsset,
    required this.color,
    required this.timestamp,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      "moodId": moodId,
      "label": label,
      "lottieAsset": lottieAsset,
      "color": color.value, //  Convert the color to int
      "timestamp": timestamp,
      "note": note,
    };
  }
  
  factory MoodModel.fromJson(Map<String, dynamic> json) {
    return MoodModel(
      moodId: json['moodId'] as String?,
      label: json['label'],
      lottieAsset: json['lottieAsset'],
      color: Color(json['color']), // Convertir el entero de vuelta a un objeto Color
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      note: json['note'] ?? '',
    );
  }

  
}
