import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/appointment.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String? _error;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAppointments() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('appointments') ?? [];
      _appointments =
          data.map((str) => Appointment.fromJson(json.decode(str))).toList()
            ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    } catch (e) {
      _error = 'Error cargando citas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addAppointment(Appointment appointment) async {
    try {
      _appointments.add(appointment);
      _appointments.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      await _saveAppointments();
      notifyListeners();
    } catch (e) {
      _error = 'Error guardando cita: $e';
      notifyListeners();
    }
  }

  Future<void> _saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data =
        _appointments
            .map((appointment) => json.encode(appointment.toJson()))
            .toList();
    await prefs.setStringList('appointments', data);
  }
}
