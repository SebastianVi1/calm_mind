import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/professional_patient_model.dart';

/// Repository for managing professional patients in Firebase
/// Handles CRUD operations for professional patient management
class ProfessionalPatientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Collection for professional patients
  CollectionReference get _patientsCollection =>
      _firestore.collection('professional_patients');

  /// Gets the current professional's ID
  String get _professionalId {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Professional not authenticated');
    return user.uid;
  }

  /// Adds a new patient to professional care
  /// [patient] - The patient to add
  /// Returns the patient ID
  Future<String> addPatient(ProfessionalPatientModel patient) async {
    try {
      print('Adding patient: ${patient.name} with ID: ${patient.userId}');

      // Check if patient already exists
      final existingPatient = await getPatientByUserId(patient.userId);
      if (existingPatient != null) {
        throw Exception('El paciente ya está en tu lista de pacientes');
      }

      // Verify that the user exists in the system
      final userDoc =
          await _firestore.collection('users').doc(patient.userId).get();
      if (!userDoc.exists) {
        throw Exception('No se encontró un usuario con ese ID');
      }

      // Update patient with professional ID
      final updatedPatient = patient.copyWith(professionalId: _professionalId);

      // Add patient to professional care
      await _patientsCollection
          .doc(updatedPatient.id)
          .set(updatedPatient.toMap());

      print('Patient added successfully');
      return updatedPatient.id;
    } catch (e) {
      print('Error adding patient: $e');
      throw Exception('Error al agregar paciente: $e');
    }
  }

  /// Gets all patients for the current professional
  /// Returns a list of ProfessionalPatientModel
  Future<List<ProfessionalPatientModel>> getMyPatients() async {
    try {
      print('Getting patients for professional: $_professionalId');

      final querySnapshot =
          await _patientsCollection
              .where('professionalId', isEqualTo: _professionalId)
              .get();

      final patients =
          querySnapshot.docs
              .map(
                (doc) => ProfessionalPatientModel.fromMap(
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();

      // Sort by addedDate descending
      patients.sort((a, b) => b.addedDate.compareTo(a.addedDate));

      print('Found ${patients.length} patients');
      return patients;
    } catch (e) {
      print('Error getting patients: $e');
      throw Exception('Error al obtener pacientes: $e');
    }
  }

  /// Gets a patient by their user ID
  /// [userId] - The user ID to search for
  /// Returns the patient or null if not found
  Future<ProfessionalPatientModel?> getPatientByUserId(String userId) async {
    try {
      final querySnapshot =
          await _patientsCollection
              .where('userId', isEqualTo: userId)
              .where('professionalId', isEqualTo: _professionalId)
              .limit(1)
              .get();

      if (querySnapshot.docs.isEmpty) return null;

      return ProfessionalPatientModel.fromMap(
        querySnapshot.docs.first.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting patient by user ID: $e');
      return null;
    }
  }

  /// Gets a patient by their professional patient ID
  /// [patientId] - The professional patient ID
  /// Returns the patient or null if not found
  Future<ProfessionalPatientModel?> getPatientById(String patientId) async {
    try {
      final doc = await _patientsCollection.doc(patientId).get();
      if (!doc.exists) return null;

      return ProfessionalPatientModel.fromMap(
        doc.data() as Map<String, dynamic>,
      );
    } catch (e) {
      print('Error getting patient by ID: $e');
      return null;
    }
  }

  /// Updates a patient's information
  /// [patient] - The updated patient model
  Future<void> updatePatient(ProfessionalPatientModel patient) async {
    try {
      print('Updating patient: ${patient.name}');

      await _patientsCollection.doc(patient.id).update(patient.toMap());

      print('Patient updated successfully');
    } catch (e) {
      print('Error updating patient: $e');
      throw Exception('Error al actualizar paciente: $e');
    }
  }

  /// Removes a patient from professional care
  /// [patientId] - The patient ID to remove
  Future<void> removePatient(String patientId) async {
    try {
      print('Removing patient: $patientId');

      await _patientsCollection.doc(patientId).delete();

      print('Patient removed successfully');
    } catch (e) {
      print('Error removing patient: $e');
      throw Exception('Error al eliminar paciente: $e');
    }
  }

  /// Gets patient statistics for the professional
  /// Returns a map with statistics
  Future<Map<String, dynamic>> getPatientStatistics() async {
    try {
      final patients = await getMyPatients();

      final activePatients =
          patients.where((p) => p.status == PatientStatus.active).length;
      final inactivePatients =
          patients.where((p) => p.status == PatientStatus.inactive).length;
      final dischargedPatients =
          patients.where((p) => p.status == PatientStatus.discharged).length;

      // Calculate average age
      final patientsWithAge = patients.where((p) => p.age != null).toList();
      final averageAge =
          patientsWithAge.isNotEmpty
              ? patientsWithAge.map((p) => p.age!).reduce((a, b) => a + b) /
                  patientsWithAge.length
              : 0.0;

      return {
        'totalPatients': patients.length,
        'activePatients': activePatients,
        'inactivePatients': inactivePatients,
        'dischargedPatients': dischargedPatients,
        'averageAge': averageAge.round(),
        'patientsWithReports': 0, // Will be calculated separately
      };
    } catch (e) {
      print('Error getting patient statistics: $e');
      return {
        'totalPatients': 0,
        'activePatients': 0,
        'inactivePatients': 0,
        'dischargedPatients': 0,
        'averageAge': 0,
        'patientsWithReports': 0,
      };
    }
  }

  /// Searches patients by name or email
  /// [query] - The search query
  /// Returns a list of matching patients
  Future<List<ProfessionalPatientModel>> searchPatients(String query) async {
    try {
      if (query.isEmpty) return await getMyPatients();

      final patients = await getMyPatients();

      return patients.where((patient) {
        final nameMatch = patient.name.toLowerCase().contains(
          query.toLowerCase(),
        );
        final emailMatch =
            patient.email?.toLowerCase().contains(query.toLowerCase()) ?? false;
        return nameMatch || emailMatch;
      }).toList();
    } catch (e) {
      print('Error searching patients: $e');
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
      await _patientsCollection.doc(patientId).update({
        'lastConsultation': Timestamp.fromDate(consultationDate),
      });
    } catch (e) {
      print('Error updating last consultation: $e');
      throw Exception('Error al actualizar última consulta: $e');
    }
  }

  /// Gets patients with recent activity (last 30 days)
  /// Returns a list of active patients
  Future<List<ProfessionalPatientModel>> getRecentPatients() async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

      final patients = await getMyPatients();

      return patients.where((patient) {
        return patient.status == PatientStatus.active &&
            (patient.lastConsultation == null ||
                patient.lastConsultation!.isAfter(thirtyDaysAgo));
      }).toList();
    } catch (e) {
      print('Error getting recent patients: $e');
      return [];
    }
  }
}
