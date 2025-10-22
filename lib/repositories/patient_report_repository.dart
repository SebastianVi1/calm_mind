import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/patient_report_model.dart';

/// Repositorio para manejar los reportes de pacientes en Firebase
/// Proporciona métodos para guardar, recuperar y gestionar reportes
class PatientReportRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Colección de reportes de pacientes
  CollectionReference get _reportsCollection => _firestore.collection('patient_reports');

  /// Documento del usuario actual
  DocumentReference get _userDoc {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuario no autenticado');
    return _reportsCollection.doc(userId);
  }

  /// Saves a new patient report
  /// [report] - The report to save
  /// Returns the ID of the saved report
  Future<String> savePatientReport(PatientReportModel report) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      print('Saving report for user: $userId');
      print('Report ID: ${report.id}');

      // Get the user document
      final userDoc = await _userDoc.get();
      
      if (!userDoc.exists) {
        // Create new document for the user
        print('Creating new document for user');
        await _userDoc.set({
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'reports': [report.toMap()],
        });
      } else {
        // Update existing document
        print('Updating existing document');
        final data = userDoc.data() as Map<String, dynamic>;
        final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);
        
        // Add the new report
        reports.add(report.toMap());
        
        await _userDoc.update({
          'reports': reports,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      print('Report saved successfully');
      return report.id;
    } catch (e) {
      print('Error saving report: $e');
      throw Exception('Error al guardar el reporte: $e');
    }
  }

  /// Gets all reports from the current user
  /// Returns a list of PatientReportModel
  Future<List<PatientReportModel>> getUserReports() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      print('Getting reports for user: $userId');
      final userDoc = await _userDoc.get();
      
      if (!userDoc.exists) {
        print('No document found for user');
        return [];
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);
      
      print('Found ${reports.length} reports in document');

      return reports.map((reportData) => PatientReportModel.fromMap(reportData)).toList();
    } catch (e) {
      print('Error getting reports: $e');
      throw Exception('Error al obtener los reportes: $e');
    }
  }

  /// Obtiene el reporte más reciente del usuario
  /// Retorna el último PatientReportModel o null si no hay reportes
  Future<PatientReportModel?> getLatestReport() async {
    try {
      final reports = await getUserReports();
      if (reports.isEmpty) return null;

      // Ordenar por fecha de creación (más reciente primero)
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reports.first;
    } catch (e) {
      throw Exception('Error al obtener el último reporte: $e');
    }
  }

  /// Obtiene un reporte específico por ID
  /// [reportId] - ID del reporte a buscar
  /// Retorna el PatientReportModel o null si no se encuentra
  Future<PatientReportModel?> getReportById(String reportId) async {
    try {
      final reports = await getUserReports();
      return reports.where((report) => report.id == reportId).firstOrNull;
    } catch (e) {
      throw Exception('Error al obtener el reporte por ID: $e');
    }
  }

  /// Actualiza un reporte existente
  /// [report] - El reporte actualizado
  Future<void> updatePatientReport(PatientReportModel report) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final userDoc = await _userDoc.get();
      if (!userDoc.exists) {
        throw Exception('No se encontró el documento del usuario');
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);

      // Encontrar y actualizar el reporte específico
      final reportIndex = reports.indexWhere((r) => r['id'] == report.id);
      if (reportIndex == -1) {
        throw Exception('Reporte no encontrado');
      }

      reports[reportIndex] = report.toMap();

      await _userDoc.update({
        'reports': reports,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al actualizar el reporte: $e');
    }
  }

  /// Elimina un reporte específico
  /// [reportId] - ID del reporte a eliminar
  Future<void> deletePatientReport(String reportId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      final userDoc = await _userDoc.get();
      if (!userDoc.exists) {
        throw Exception('No se encontró el documento del usuario');
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);

      // Filtrar el reporte a eliminar
      final updatedReports = reports.where((r) => r['id'] != reportId).toList();

      await _userDoc.update({
        'reports': updatedReports,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error al eliminar el reporte: $e');
    }
  }

  /// Obtiene estadísticas de los reportes del usuario
  /// Retorna un mapa con estadísticas básicas
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final reports = await getUserReports();
      
      if (reports.isEmpty) {
        return {
          'totalReports': 0,
          'averageWellnessScore': 0,
          'riskLevelDistribution': {'low': 0, 'medium': 0, 'high': 0},
          'latestReportDate': null,
        };
      }

      // Calcular estadísticas
      final totalReports = reports.length;
      final averageWellnessScore = reports.map((r) => r.wellnessScore).reduce((a, b) => a + b) / totalReports;
      
      final riskLevelDistribution = <String, int>{
        'low': reports.where((r) => r.riskLevel == RiskLevel.low).length,
        'medium': reports.where((r) => r.riskLevel == RiskLevel.medium).length,
        'high': reports.where((r) => r.riskLevel == RiskLevel.high).length,
      };

      // Obtener la fecha del reporte más reciente
      reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final latestReportDate = reports.first.createdAt;

      return {
        'totalReports': totalReports,
        'averageWellnessScore': averageWellnessScore.round(),
        'riskLevelDistribution': riskLevelDistribution,
        'latestReportDate': latestReportDate,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  /// Stream de reportes del usuario para actualizaciones en tiempo real
  /// Retorna un Stream<List<PatientReportModel>>
  Stream<List<PatientReportModel>> getUserReportsStream() {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('Usuario no autenticado');

      return _userDoc.snapshots().map((snapshot) {
        if (!snapshot.exists) return <PatientReportModel>[];

        final data = snapshot.data() as Map<String, dynamic>;
        final reports = List<Map<String, dynamic>>.from(data['reports'] ?? []);

        return reports.map((reportData) => PatientReportModel.fromMap(reportData)).toList();
      });
    } catch (e) {
      throw Exception('Error al obtener stream de reportes: $e');
    }
  }

  /// Verifica si el usuario tiene reportes
  /// Retorna true si tiene al menos un reporte
  Future<bool> hasReports() async {
    try {
      final reports = await getUserReports();
      return reports.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Obtiene reportes por rango de fechas
  /// [startDate] - Fecha de inicio
  /// [endDate] - Fecha de fin
  /// Retorna lista de reportes en el rango especificado
  Future<List<PatientReportModel>> getReportsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final reports = await getUserReports();
      
      return reports.where((report) {
        return report.createdAt.isAfter(startDate.subtract(const Duration(days: 1))) &&
               report.createdAt.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();
    } catch (e) {
      throw Exception('Error al obtener reportes por rango de fechas: $e');
    }
  }
}
