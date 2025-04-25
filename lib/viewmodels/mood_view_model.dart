import 'package:flutter/material.dart';
import 'package:re_mind/models/mood_model.dart';
import 'package:fl_chart/fl_chart.dart';

/// MoodViewModel manages the user's mood state and history
/// This class handles available moods, the currently selected mood,
/// and maintains a history of previously selected moods
class MoodViewModel extends ChangeNotifier{
  /// List of all available moods that users can select from
  final List<MoodModel> availableMoods = [
    MoodModel(
      label: 'Feliz', 
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
      label: 'Enojado', 
      lottieAsset: 'assets/animations/angry_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.orangeAccent
    ),
    MoodModel(
      label: 'Triste', 
      lottieAsset: 'assets/animations/sad_emoji.json', 
      timestamp: DateTime.now(),
      color: Colors.grey
    ),

  ];
  
  /// History of all moods selected by the user
  /// Each entry includes the mood and when it was selected
  List<MoodModel> moodHistory = [];

  /// The currently selected mood
  MoodModel? _selectedMood;
  
  /// Getter for the currently selected mood
  MoodModel? get selectedMood => _selectedMood;

  /// Controller for the note input text field
  TextEditingController noteController = TextEditingController();
  
  /// Selects a mood but does not add it to history yet
  void selectMood(MoodModel mood) {
    _selectedMood = mood;
    notifyListeners();
  }
  
  /// Saves the currently selected mood with optional note to history
  /// Call this when user presses the submit button
  void saveMoodEntry() {
    if (_selectedMood == null) return;
    
    // Create a copy of the mood with the current timestamp and note
    final moodWithCurrentTime = MoodModel(
      label: _selectedMood!.label,
      lottieAsset: _selectedMood!.lottieAsset,
      color: _selectedMood!.color,
      timestamp: DateTime.now(),
      note: noteController.text.isNotEmpty ? noteController.text : null,
    );

    // Add the timestamped mood to history
    moodHistory.add(moodWithCurrentTime);
    
    // Clear the note
    noteController.clear();
    
    // Reset the selected mood
    _selectedMood = null;
    
    // Notify listeners about the change
    notifyListeners();
  }
  
  /// Reset current mood selection and note
  void resetMoodSelection() {
    _selectedMood = null;
    noteController.clear();
    notifyListeners();
  }

  /// Gets all moods recorded for a specific date
  /// @param date The date to get moods for
  /// @return List of moods recorded on the specified date
  List<MoodModel> getMoodsForDate(DateTime date) {
    return moodHistory.where((mood) {
      
      final moodDate = mood.timestamp;
      // Match year, month and day to filter moods for the specific date
      return moodDate.year == date.year &&
          moodDate.month == date.month &&
          moodDate.day == date.day;
    }).toList();
  }
  
  /// Gets the entire mood history
  List<MoodModel> getAllMoodHistory() {
    return List.from(moodHistory.reversed); // Most recent first
  }

  // Método para obtener los datos para la gráfica
  List<FlSpot> getMoodChartData() {
    // Agrupar los estados de ánimo por día
    Map<int, List<MoodModel>> moodsByDay = {};
    
    for (var mood in moodHistory) {
      final day = mood.timestamp.day;
      moodsByDay.putIfAbsent(day, () => []).add(mood);
    }

    // Calcular el promedio para cada día
    List<FlSpot> spots = [];
    moodsByDay.forEach((day, moods) {
      double sum = 0;
      for (var mood in moods) {
        switch (mood.label.toLowerCase()) {
          case 'feliz':
            sum += 4.0;  // Ajustado de 5.0 a 4.0
            break;
          case 'neutral':
            sum += 3.0;
            break;
          case 'triste':
            sum += 1.0;
            break;
          case 'enojado':
            sum += 2.0;
            break;
          default:
            sum += 3.0;
        }
      }
      double average = sum / moods.length;
      spots.add(FlSpot(day.toDouble(), average));
    });

    // Ordenar los puntos por día
    spots.sort((a, b) => a.x.compareTo(b.x));
    
    return spots;
  }

  String getMoodTrend() {
    if (moodHistory.length < 2) return "Necesitas más datos";
    
    final recentMoods = moodHistory.take(5).toList();
    double sum = 0;
    for (var mood in recentMoods) {
      switch (mood.label.toLowerCase()) {
        case 'feliz':
          sum += 5;
        case 'neutral':
          sum += 3;
        case 'triste':
          sum += 1;
        case 'enojado':
          sum += 2;
      }
    }
    double average = sum / recentMoods.length;
    
    if (average > 3.5) return "Tendencia positiva 📈";
    if (average < 2.5) return "Tendencia negativa 📉";
    return "Tendencia estable ↔️";
  }

  List<MoodModel> filterMoods(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    switch (filter) {
      case 'hoy':
        return moodHistory.where((mood) {
          final moodDate = mood.timestamp;
          return moodDate.year == today.year &&
                 moodDate.month == today.month &&
                 moodDate.day == today.day;
        }).toList().reversed.toList(); // Most recent first

      case 'semanal':
        return moodHistory.where((mood) {
          return mood.timestamp.isAfter(weekAgo) || 
                 mood.timestamp.isAtSameMomentAs(weekAgo);
        }).toList().reversed.toList(); // Most recent first

      case 'todos':
        return List.from(moodHistory.reversed); // Most recent first

      default:
        return List.from(moodHistory.reversed); // Most recent first
    }
  }
}