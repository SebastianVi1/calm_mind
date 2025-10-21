// ViewModel that handles the appointments state and persistence
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/appointment.dart';

// Manages appointments data and operations using ChangeNotifier pattern
class AppointmentViewModel extends ChangeNotifier {
  // Internal list of appointments
  List<Appointment> _appointments = [];
  // Loading state flag
  bool _isLoading = false;
  // Error message if any operation fails
  String? _error;

  // Getters for public access
  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load appointments from SharedPreferences and sort them by date
  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('appointments') ?? [];
      // Parse JSON strings to Appointment objects and sort by date
      _appointments =
          data.map((str) => Appointment.fromJson(json.decode(str))).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      _error = 'Error loading appointments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new appointment and save to persistent storage
  Future<void> addAppointment(Appointment appointment) async {
    try {
      _appointments.add(appointment);
      // Keep appointments sorted by date
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Error saving appointment: $e';
      notifyListeners();
    }
  }

  // Delete appointment by id
  Future<void> deleteAppointment(String id) async {
    try {
      _appointments.removeWhere((appointment) => appointment.id == id);
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Error deleting appointment: $e';
      notifyListeners();
    }
  }

  // Toggle appointment done status
  Future<void> toggleAppointmentStatus(String id) async {
    try {
      final index = _appointments.indexWhere(
        (appointment) => appointment.id == id,
      );
      if (index != -1) {
        final appointment = _appointments[index];
        _appointments[index] = Appointment(
          id: appointment.id,
          patientId: appointment.patientId,
          patientName: appointment.patientName,
          patientPhone: appointment.patientPhone,
          dateTime: appointment.dateTime,
          notes: appointment.notes,
          isDone: !appointment.isDone,
        );
        await _saveAppointments();
        notifyListeners();
      }
    } catch (e) {
      _error = 'Error updating appointment status: $e';
      notifyListeners();
    }
  }

  // Private method to persist appointments to SharedPreferences
  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    // Convert appointments to JSON strings for storage
    final data =
        _appointments
            .map((appointment) => json.encode(appointment.toJson()))
            .toList();
    await prefs.setStringList('appointments', data);
  }
}
