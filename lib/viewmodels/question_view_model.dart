import 'package:flutter/material.dart';
import '../models/question_model.dart';

/// ViewModel for managing the state of the onboarding questions
/// Extends ChangeNotifier to notify listeners of state changes
class QuestionViewModel extends ChangeNotifier {
  /// List of predefined questions for the onboarding process
  final List<QuestionModel> questions = [
    QuestionModel(
      question: '¿Cuál es tu nombre?',
      options: ['Juan', 'María', 'Pedro', 'Ana'],
      description: 'Descripción de la pregunta 1',
    ),
    QuestionModel(
      question: '¿Cuál es tu edad?',
      options: ['18-25', '26-35', '36-45', '46+'],
      description: 'Descripción de la pregunta 2',
    ),
    QuestionModel(
      question: '¿Cuál es tu nivel de educación?',
      options: ['Primaria', 'Secundaria', 'Universidad', 'Postgrado'],
      description: 'Descripción de la pregunta 3',
    ),
  ];

  /// Current question index in the questions list
  int _currentQuestionIndex = 0;
  
  /// List of user's answers
  List<String> _answers = [];

  // Getters for accessing private state
  int get currentQuestionIndex => _currentQuestionIndex;
  List<String> get answers => _answers;
  QuestionModel get currentQuestion => questions[_currentQuestionIndex];
  bool get isLastQuestion => _currentQuestionIndex == questions.length - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;
  
  /// Gets the current answer or empty string if not answered
  String get currentAnswer => 
      _answers.length > _currentQuestionIndex ? _answers[_currentQuestionIndex] : '';
  
  /// Checks if the current question has been answered
  bool get hasAnsweredCurrentQuestion => currentAnswer.isNotEmpty;

  /// Updates the answer for the current question
  /// If the answer array is shorter than the current index, adds a new answer
  /// Otherwise updates the existing answer
  void selectAnswer(String answer) {
    if (_answers.length <= _currentQuestionIndex) {
      _answers.add(answer);
    } else {
      _answers[_currentQuestionIndex] = answer;
    }
    notifyListeners();
  }

  /// Moves to the next question if available
  void nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Moves to the previous question if available
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Resets the onboarding process to the first question
  void reset() {
    _currentQuestionIndex = 0;
    _answers = [];
    notifyListeners();
  }
} 