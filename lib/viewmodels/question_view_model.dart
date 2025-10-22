import 'package:calm_mind/models/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/question_model.dart';
import '../models/patient_report_model.dart';
import '../services/user_service.dart';
import '../services/patient_report_service.dart';
import '../repositories/patient_report_repository.dart';

/// ViewModel for managing the state of the onboarding questions
/// Handles question navigation, answer selection, and saving answers
class QuestionViewModel extends ChangeNotifier {
  /// Service for saving user data and answers
  final UserService _userService = UserService();
  
  /// Service for generating patient reports
  final PatientReportService _reportService = PatientReportService();
  
  /// Repository for managing patient reports
  final PatientReportRepository _reportRepository = PatientReportRepository();

  /// List of predefined questions for the onboarding process
  /// Each question has text, description, and multiple choice options
  final List<QuestionModel> questions = [
    QuestionModel(
      question: '¿Te sientes triste o vacío la mayor parte del tiempo?',
      options: ['Sí', 'No'],
      description:
          'Es importante reconocer nuestros sentimientos para poder manejarlos mejor',
    ),
    QuestionModel(
      question:
          '¿Sientes una preocupación excesiva por situaciones cotidianas?',
      options: ['Sí', 'No'],
      description:
          'La ansiedad puede manifestarse de diferentes maneras en nuestra vida diaria',
    ),
    QuestionModel(
      question: '¿Has perdido interés en actividades que antes disfrutabas?',
      options: ['Sí', 'No'],
      description:
          'Los cambios en nuestros intereses pueden indicar cambios en nuestro estado de ánimo',
    ),
    QuestionModel(
      question:
          '¿Experimentas dificultad para relajarte, incluso en momentos de descanso?',
      options: ['Sí', 'No'],
      description:
          'La capacidad de relajarnos es fundamental para nuestra salud mental',
    ),
    QuestionModel(
      question:
          '¿Tienes problemas para dormir debido a pensamientos constantes?',
      options: ['Sí', 'No'],
      description:
          'El sueño es esencial para nuestro bienestar físico y mental',
    ),
    QuestionModel(
      question: '¿Te sientes fatigado o sin energía constantemente?',
      options: ['Sí', 'No'],
      description:
          'La energía física y mental están estrechamente relacionadas',
    ),
    QuestionModel(
      question: '¿Evitas situaciones sociales por miedo o incomodidad extrema?',
      options: ['Sí', 'No'],
      description:
          'Las relaciones sociales son importantes para nuestro desarrollo personal',
    ),
    QuestionModel(
      question:
          '¿Experimentas cambios en tu apetito o peso sin razón aparente?',
      options: ['Sí', 'No'],
      description:
          'Los cambios en nuestros hábitos alimenticios pueden reflejar nuestro estado emocional',
    ),
    QuestionModel(
      question: '¿Te cuesta encontrar motivación para realizar tareas diarias?',
      options: ['Sí', 'No'],
      description: 'La motivación es clave para mantener una rutina saludable',
    ),
    QuestionModel(
      question: '¿Has tenido pensamientos sobre la muerte o el suicidio?',
      options: ['Sí', 'No'],
      description:
          'Es importante hablar sobre estos pensamientos y buscar ayuda profesional',
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
      _answers.length > _currentQuestionIndex
          ? _answers[_currentQuestionIndex]
          : '';

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
      throw Exception(
        'Por favor responde todas las preguntas antes de continuar',
      );
    }
    for (var answer in _answers) {
      if (answer.isEmpty) {
        throw Exception(
          'Por favor responde todas las preguntas antes de continuar',
        );
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
        throw Exception(
          'Error al guardar las respuestas. Por favor intenta nuevamente.',
        );
      }
    }
  }

  /// Saves answers and generates a patient report
  /// @throws Exception if not all questions have been answered or report generation fails
  Future<PatientReportModel> saveAnswersAndGenerateReport() async {
    _validateAnswers();

    try {
      // First save the answers
      await saveAnswers();
    
      // Get current user data
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser == null) {
        throw Exception('Usuario no autenticado');
      }
      
      final currentUser = await _userService.getUserData(firebaseUser.uid);
      if (currentUser == null) {
        throw Exception('No se pudo obtener la información del usuario');
      }

      // Generate the patient report using AI
      final report = await _reportService.generatePatientReport(
        user: currentUser,
        questionnaireAnswers: _answers,
        questions: questions,
      );

      // Save the report to Firebase
      await _reportRepository.savePatientReport(report);

      return report;
    } catch (e) {
      throw Exception(
        'Error al guardar las respuestas y generar el reporte: $e',
      );
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
