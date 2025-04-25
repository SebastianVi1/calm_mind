import 'dart:ui';

class MoodModel{
  String label;
  String lottieAsset;
  final Color color;
  final DateTime timestamp;
  final String? note;
  MoodModel({
    required this.label,
    required this.lottieAsset,
    required this.color,
    required this.timestamp,
    this.note,
  });

  
  
  
}