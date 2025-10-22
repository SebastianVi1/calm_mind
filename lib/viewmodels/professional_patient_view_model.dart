import 'package:calm_mind/models/patient_report_model.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/professional_patient_model.dart';
import '../repositories/professional_patient_repository.dart';
import '../services/user_service.dart';
import 'patient_report_view_model.dart';

/// ViewModel for managing professional patients
/// Handles patient management, search, and statistics
class ProfessionalPatientViewModel extends ChangeNotifier {
  final ProfessionalPatientRepository _repository =
      ProfessionalPatientRepository();
  final UserService _userService = UserService();
  final _uuid = const Uuid();

  /// List of professional patients
  List<ProfessionalPatientModel> _patients = [];

  /// Currently selected patient
  ProfessionalPatientModel? _selectedPatient;

  /// Search query for filtering patients
  String _searchQuery = '';

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Statistics data
  Map<String, dynamic>? _statistics;

  // Getters
  List<ProfessionalPatientModel> get patients => _patients;
  ProfessionalPatientModel? get selectedPatient => _selectedPatient;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic>? get statistics => _statistics;
  bool get hasPatients => _patients.isNotEmpty;

  /// Gets filtered patients based on search query
  List<ProfessionalPatientModel> get filteredPatients {
    if (_searchQuery.isEmpty) return _patients;

    return _patients.where((patient) {
      final nameMatch = patient.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final emailMatch =
          patient.email?.toLowerCase().contains(_searchQuery.toLowerCase()) ??
          false;
      return nameMatch || emailMatch;
    }).toList();
  }

  /// Loads all patients for the current professional
  Future<void> loadPatients() async {
    try {
      _setLoading(true);
      _clearError();

      print('Loading professional patients...');
      final patientList = await _repository.getMyPatients();

      _patients = patientList;

      // Select first patient if none selected
      if (_selectedPatient == null && _patients.isNotEmpty) {
        _selectedPatient = _patients.first;
      }

      print('Loaded ${_patients.length} patients');
      notifyListeners();
    } catch (e) {
      print('Error loading patients: $e');
      _setError('Error al cargar pacientes: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Adds a new patient by user ID
  Future<bool> addPatientByUserId({
    required String userId,
    required String name, // Add required name parameter
    String? professionalNotes,
    int? age,
    String? gender,
    String? emergencyContact,
    String? medicalHistory,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final patient = ProfessionalPatientModel(
        id: _uuid.v4(),
        userId: userId,
        name: name, // Use provided name instead of default
        email: null,
        professionalNotes: professionalNotes,
        addedDate: DateTime.now(),
        status: PatientStatus.active,
        professionalId: '',
        age: age,
        gender: gender,
        emergencyContact: emergencyContact,
        medicalHistory: medicalHistory,
      );

      await _repository.addPatient(patient);
      await loadPatients();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Updates a patient's information
  /// [patient] - The updated patient model
  Future<bool> updatePatient(ProfessionalPatientModel patient) async {
    try {
      _setLoading(true);
      _clearError();

      await _repository.updatePatient(patient);

      // Update local list
      final index = _patients.indexWhere((p) => p.id == patient.id);
      if (index != -1) {
        _patients[index] = patient;
      }

      // Update selected patient if it's the same
      if (_selectedPatient?.id == patient.id) {
        _selectedPatient = patient;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar paciente: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Removes a patient from professional care
  /// [patientId] - The patient ID to remove
  Future<bool> removePatient(String patientId) async {
    try {
      _setLoading(true);
      _clearError();

      await _repository.removePatient(patientId);

      // Remove from local list
      _patients.removeWhere((p) => p.id == patientId);

      // Clear selection if removed patient was selected
      if (_selectedPatient?.id == patientId) {
        _selectedPatient = _patients.isNotEmpty ? _patients.first : null;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al eliminar paciente: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Selects a patient
  /// [patient] - The patient to select
  void selectPatient(ProfessionalPatientModel patient) {
    _selectedPatient = patient;
    notifyListeners();
  }

  /// Updates the search query
  /// [query] - The search query
  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Clears the search query
  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  /// Loads patient statistics
  Future<void> loadStatistics() async {
    try {
      _setLoading(true);
      _clearError();

      print('Loading patient statistics...');
      _statistics = await _repository.getPatientStatistics();

      print('Statistics loaded: $_statistics');
      notifyListeners();
    } catch (e) {
      print('Error loading statistics: $e');
      _setError('Error al cargar estadísticas: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Gets patients with recent activity
  Future<List<ProfessionalPatientModel>> getRecentPatients() async {
    try {
      return await _repository.getRecentPatients();
    } catch (e) {
      print('Error getting recent patients: $e');
      return [];
    }
  }

  /// Updates patient's last consultation date
  /// [patientId] - The patient ID
  /// [consultationDate] - The consultation date
  Future<void> updateLastConsultation(
    String patientId,
    DateTime consultationDate,
  ) async {
    try {
      await _repository.updateLastConsultation(patientId, consultationDate);

      // Update local patient data
      final patient = _patients.firstWhere((p) => p.id == patientId);
      final updatedPatient = patient.copyWith(
        lastConsultation: consultationDate,
      );

      final index = _patients.indexWhere((p) => p.id == patientId);
      if (index != -1) {
        _patients[index] = updatedPatient;
      }

      if (_selectedPatient?.id == patientId) {
        _selectedPatient = updatedPatient;
      }

      notifyListeners();
    } catch (e) {
      _setError('Error al actualizar consulta: $e');
    }
  }

  /// Refreshes all data
  Future<void> refresh() async {
    await loadPatients();
    await loadStatistics();
  }

  /// Clears all data
  void clear() {
    _patients.clear();
    _selectedPatient = null;
    _searchQuery = '';
    _statistics = null;
    _clearError();
    notifyListeners();
  }

  /// Sets the loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// Sets an error message
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  /// Clears the error message
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Gets the color for patient status
  Color getStatusColor(PatientStatus status) {
    switch (status) {
      case PatientStatus.active:
        return Colors.green;
      case PatientStatus.inactive:
        return Colors.orange;
      case PatientStatus.discharged:
        return Colors.red;
    }
  }

  /// Gets the icon for patient status
  IconData getStatusIcon(PatientStatus status) {
    switch (status) {
      case PatientStatus.active:
        return Icons.check_circle;
      case PatientStatus.inactive:
        return Icons.pause_circle;
      case PatientStatus.discharged:
        return Icons.cancel;
    }
  }

  /// Loads patient reports
  Future<List<PatientReportModel>> loadPatientReports(String userId) async {
    try {
      _setLoading(true);

      // Get report viewmodel and load reports
      final reportViewModel = PatientReportViewModel();
      await reportViewModel.loadUserReportsByUserId(userId);

      print(
        'DEBUG: Loaded ${reportViewModel.reports.length} reports for patient $userId',
      );

      notifyListeners();
      print(reportViewModel.reports);
      return reportViewModel.reports;
    } catch (e) {
      print('ERROR: Failed to load patient reports: $e');
      _setError('Error al cargar reportes del paciente: $e');
      return [];
    } finally {
      _setLoading(false);
    }
  }
}
