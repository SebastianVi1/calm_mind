import 'package:flutter/material.dart';
import '../models/patient_report_model.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';
import '../services/patient_report_service.dart';
import '../repositories/patient_report_repository.dart';
import '../services/auth/firebase_auth_service.dart';

/// ViewModel para manejar la lógica de reportes de pacientes
/// Gestiona la generación, almacenamiento y recuperación de reportes
class PatientReportViewModel extends ChangeNotifier {
  final PatientReportService _reportService = PatientReportService();
  final PatientReportRepository _reportRepository = PatientReportRepository();

  /// Lista de reportes del usuario
  List<PatientReportModel> _reports = [];

  /// Reporte actualmente seleccionado
  PatientReportModel? _selectedReport;

  /// Estado de carga para operaciones asíncronas
  bool _isLoading = false;

  /// Mensaje de error si ocurre alguno
  String? _errorMessage;

  /// Estadísticas de los reportes
  Map<String, dynamic>? _statistics;

  // Getters
  List<PatientReportModel> get reports => _reports;
  PatientReportModel? get selectedReport => _selectedReport;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;
  bool get hasReports => _reports.isNotEmpty;
  PatientReportModel? get latestReport => _reports.isNotEmpty ? _reports.first : null;

  /// Genera un nuevo reporte basado en las respuestas del cuestionario
  /// [questionnaireAnswers] - Respuestas del cuestionario
  /// [questions] - Lista de preguntas
  Future<PatientReportModel?> generateReport({
    required List<String> questionnaireAnswers,
    required List<QuestionModel> questions,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Obtener información del usuario actual
      final currentUser = await _getCurrentUser();
      if (currentUser == null) {
        throw Exception('No se pudo obtener la información del usuario');
      }

      // Generar el reporte usando IA
      final newReport = await _reportService.generatePatientReport(
        user: currentUser,
        questionnaireAnswers: questionnaireAnswers,
        questions: questions,
      );

      // Guardar el reporte en Firebase
      await _reportRepository.savePatientReport(newReport);

      // Actualizar la lista local
      _reports.insert(0, newReport); // Insertar al inicio para mantener orden cronológico
      _selectedReport = newReport;

      notifyListeners();
      return newReport;
    } catch (e) {
      _setError('Error al generar el reporte: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Loads all user reports
  Future<void> loadUserReports() async {
    try {
      _setLoading(true);
      _clearError();

      print('Loading user reports...');
      final userReports = await _reportRepository.getUserReports();
      print('Found ${userReports.length} reports');
      
      // Sort by creation date (most recent first)
      userReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      _reports = userReports;
      
      // If no report is selected, select the most recent one
      if (_selectedReport == null && _reports.isNotEmpty) {
        _selectedReport = _reports.first;
      }

      print('Reports loaded successfully: ${_reports.length}');
      notifyListeners();
    } catch (e) {
      print('Error loading reports: $e');
      _setError('Error al cargar los reportes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Selecciona un reporte específico
  /// [report] - El reporte a seleccionar
  void selectReport(PatientReportModel report) {
    _selectedReport = report;
    notifyListeners();
  }

  /// Obtiene un reporte por ID
  /// [reportId] - ID del reporte
  Future<PatientReportModel?> getReportById(String reportId) async {
    try {
      _setLoading(true);
      _clearError();

      final report = await _reportRepository.getReportById(reportId);
      if (report != null) {
        _selectedReport = report;
      }

      notifyListeners();
      return report;
    } catch (e) {
      _setError('Error al obtener el reporte: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Elimina un reporte específico
  /// [reportId] - ID del reporte a eliminar
  Future<bool> deleteReport(String reportId) async {
    try {
      _setLoading(true);
      _clearError();

      await _reportRepository.deletePatientReport(reportId);

      // Remover de la lista local
      _reports.removeWhere((report) => report.id == reportId);

      // Si el reporte eliminado era el seleccionado, seleccionar otro
      if (_selectedReport?.id == reportId) {
        _selectedReport = _reports.isNotEmpty ? _reports.first : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar el reporte: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Carga las estadísticas de los reportes
  Future<void> loadStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      _statistics = await _reportRepository.getReportStatistics();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar estadísticas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Obtiene reportes por rango de fechas
  /// [startDate] - Fecha de inicio
  /// [endDate] - Fecha de fin
  Future<List<PatientReportModel>> getReportsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final filteredReports = await _reportRepository.getReportsByDateRange(
        startDate: startDate,
        endDate: endDate,
      );

      notifyListeners();
      return filteredReports;
    } catch (e) {
      _setError('Error al obtener reportes por fecha: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }

  /// Genera un resumen rápido del reporte seleccionado
  String? getQuickSummary() {
    if (_selectedReport == null) return null;
    return _reportService.generateQuickSummary(_selectedReport!);
  }

  /// Obtiene el nivel de riesgo del reporte seleccionado
  RiskLevel? getSelectedReportRiskLevel() {
    return _selectedReport?.riskLevel;
  }

  /// Obtiene la puntuación de bienestar del reporte seleccionado
  int? getSelectedReportWellnessScore() {
    return _selectedReport?.wellnessScore;
  }

  /// Verifica si el usuario tiene reportes
  Future<bool> checkHasReports() async {
    try {
      return await _reportRepository.hasReports();
    } catch (e) {
      return false;
    }
  }

  /// Refresca los datos del usuario
  Future<void> refresh() async {
    await loadUserReports();
    await loadStatistics();
  }

  /// Limpia todos los datos
  void clear() {
    _reports.clear();
    _selectedReport = null;
    _statistics = null;
    _clearError();
    notifyListeners();
  }

  /// Obtiene el usuario actual
  Future<UserModel?> _getCurrentUser() async {
    try {
      final authService = FirebaseAuthService();
      return await authService.getCurrentUser();
    } catch (e) {
      return null;
    }
  }

  /// Establece el estado de carga
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Establece un mensaje de error
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Limpia el mensaje de error
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Obtiene el color asociado al nivel de riesgo
  Color getRiskLevelColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  /// Obtiene el icono asociado al nivel de riesgo
  IconData getRiskLevelIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  /// Obtiene el color de la puntuación de bienestar
  Color getWellnessScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  /// Formatea una fecha para mostrar
  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Obtiene el texto descriptivo del nivel de riesgo
  String getRiskLevelDescription(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'El paciente muestra indicadores positivos de bienestar mental. Se recomienda mantener las prácticas actuales y continuar con el seguimiento regular.';
      case RiskLevel.medium:
        return 'Se identifican algunas áreas de preocupación que requieren atención. Se recomienda implementar estrategias de apoyo y considerar consulta profesional.';
      case RiskLevel.high:
        return 'Se detectan múltiples indicadores de riesgo que requieren atención inmediata. Se recomienda derivación urgente a profesional de salud mental.';
    }
  }
}
