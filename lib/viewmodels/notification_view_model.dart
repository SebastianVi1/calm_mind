import 'package:flutter/material.dart';
import 'package:calm_mind/models/notification_preferences.dart';
import 'package:calm_mind/services/notification_service.dart';
import 'package:calm_mind/services/user_service.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationService _notificationService;
  final UserService _userService;

  NotificationPreferences _prefs = const NotificationPreferences();
  NotificationPreferences get prefs => _prefs;

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  NotificationViewModel(this._notificationService, this._userService);

  Future<void> loadPreferences(String uid) async {
    _loading = true;
    notifyListeners();

    try {
      final map = await _userService.getNotificationPreferences(uid);
      _prefs = NotificationPreferences.fromMap(map);
      _error = null;
    } catch (e) {
      _error = 'Error al cargar preferencias: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> savePreferences(NotificationPreferences newPrefs) async {
    _loading = true;
    notifyListeners();

    try {
      await _userService.updateNotificationPreferences(newPrefs.toMap());
      _prefs = newPrefs;
      _error = null;

      // Reschedule all notifications
      await _notificationService.rescheduleAll(_prefs);
    } catch (e) {
      _error = 'Error al guardar preferencias: $e';
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> toggleMeditation(bool value) async {
    await savePreferences(_prefs.copyWith(meditationEnabled: value));
  }

  Future<void> setMeditationTime(int hour, int minute) async {
    await savePreferences(
      _prefs.copyWith(meditationHour: hour, meditationMinute: minute),
    );
  }

  Future<void> toggleMoodCheckIn(bool value) async {
    await savePreferences(_prefs.copyWith(moodCheckInEnabled: value));
  }

  Future<void> setMoodCheckInTime(int hour, int minute) async {
    await savePreferences(
      _prefs.copyWith(moodCheckInHour: hour, moodCheckInMinute: minute),
    );
  }

  Future<void> toggleWindDown(bool value) async {
    await savePreferences(_prefs.copyWith(windDownEnabled: value));
  }

  Future<void> setWindDownTime(int hour, int minute) async {
    await savePreferences(
      _prefs.copyWith(windDownHour: hour, windDownMinute: minute),
    );
  }

  Future<void> toggleMotivationalTips(bool value) async {
    await savePreferences(_prefs.copyWith(motivationalTipsEnabled: value));
  }

  Future<void> setTipsFrequency(String frequency) async {
    await savePreferences(_prefs.copyWith(tipsFrequency: frequency));
  }

  Future<void> toggleAppointments(bool value) async {
    await savePreferences(_prefs.copyWith(appointmentsEnabled: value));
  }

  Future<void> setAppointmentAdvance(int minutes) async {
    await savePreferences(
      _prefs.copyWith(appointmentAdvanceMinutes: minutes),
    );
  }

  Future<void> scheduleAppointmentReminder(
    int appointmentId,
    DateTime dateTime,
    String patientName,
  ) async {
    if (!_prefs.appointmentsEnabled) return;

    final reminderId = 2000 + (appointmentId.hashCode % 1000).abs();
    await _notificationService.cancelAppointmentReminder(reminderId);
    await _notificationService.scheduleAppointmentReminder(
      reminderId,
      dateTime,
      _prefs.appointmentAdvanceMinutes,
      patientName,
    );
  }

  Future<void> cancelAppointmentReminder(int appointmentId) async {
    final reminderId = 2000 + (appointmentId.hashCode % 1000).abs();
    await _notificationService.cancelAppointmentReminder(reminderId);
  }

}
