import 'package:flutter/material.dart';
import 'package:re_mind/models/mood_model.dart';

class MoodViewModel extends ChangeNotifier{
  final List<MoodModel> availableMoods = [
    MoodModel(
      label: 'Happy', 
      lottieAsset: 'assets/animations/happy_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.blue
    ),
    MoodModel(
      label: 'Neutral', 
      lottieAsset: 'assets/animations/neutral_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.green
    ),
    MoodModel(
      label: 'Angry', 
      lottieAsset: 'assets/animations/angry_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.orangeAccent
    ),
    MoodModel(
      label: 'Sad', 
      lottieAsset: 'assets/animations/sad_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.grey
    ),

  ];

  MoodModel? _selectedMood;
  MoodModel? get selectedMood => _selectedMood;

  void updateMood(MoodModel mood) {
    _selectedMood = mood;
    notifyListeners();
  }


}