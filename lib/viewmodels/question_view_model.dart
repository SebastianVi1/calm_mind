import 'package:flutter/material.dart';
import '../models/question_model.dart';
import '../services/user_service.dart';

/// ViewModel for managing the state of the onboarding questions
/// Handles question navigation, answer selection, and saving answers
class QuestionViewModel extends ChangeNotifier {
  /// Service for saving user data and answers
  final UserService _userService = UserService();

  /// List of predefined questions for the onboarding process
  /// Each question has text, description, and multiple choice options
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
  
  /// List of user's answers, one for each question
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
  /// @param answer - The selected answer for the current question
  void selectAnswer(String answer) {
    if (_answers.length <= _currentQuestionIndex) {
      _answers.add(answer);
    } else {
      _answers[_currentQuestionIndex] = answer;
    }
    notifyListeners();
  }

  /// Moves to the next question if available
  /// Updates the current question index and notifies listeners
  void nextQuestion() {
    if (_currentQuestionIndex < questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  /// Moves to the previous question if available
  /// Updates the current question index and notifies listeners
  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  /// Validates that all questions have been answered
  /// @throws Exception if any question is unanswered
  void _validateAnswers() {
    if (_answers.length != questions.length) {
      throw Exception('Por favor responde todas las preguntas antes de continuar');
    }
    for (var answer in _answers) {
      if (answer.isEmpty) {
        throw Exception('Por favor responde todas las preguntas antes de continuar');
      }
    }
  }

  /// Saves the answers and creates an anonymous user if not authenticated
  /// First tries to save to authenticated user, falls back to anonymous user
  /// @throws Exception if not all questions have been answered
  Future<void> saveAnswers() async {
    _validateAnswers();

    try {
      await _userService.saveQuestionAnswers(_answers);
    } catch (e) {
      // If saving fails (user not authenticated), create anonymous user
      try {
        await _userService.createAnonymousUser(_answers);
      } catch (e) {
        throw Exception('Error al guardar las respuestas. Por favor intenta nuevamente.');
      }
    }
  }

  /// Resets the onboarding process to the first question
  /// Clears all answers and resets the question index
  void reset() {
    _currentQuestionIndex = 0;
    _answers = [];
    notifyListeners();
  }
} 