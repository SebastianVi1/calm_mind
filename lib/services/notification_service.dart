import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:calm_mind/models/notification_preferences.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String _meditationChannelId = 'meditation_reminder';
  static const String _meditationChannelName = 'Recordatorio de meditación';
  static const String _moodChannelId = 'mood_checkin';
  static const String _moodChannelName = 'Registro de ánimo';
  static const String _windDownChannelId = 'evening_winddown';
  static const String _windDownChannelName = 'Relajación nocturna';
  static const String _tipsChannelId = 'motivational_tips';
  static const String _tipsChannelName = 'Consejos motivacionales';
  static const String _appointmentsChannelId = 'appointment_reminders';
  static const String _appointmentsChannelName = 'Recordatorios de cita';

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
      ),
    );

    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _meditationChannelId,
          _meditationChannelName,
          description: 'Recordatorios diarios para tu sesión de meditación',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _moodChannelId,
          _moodChannelName,
          description: 'Recordatorios para registrar cómo te sientes',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _windDownChannelId,
          _windDownChannelName,
          description: 'Recordatorios para tu rutina de relajación nocturna',
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _tipsChannelId,
          _tipsChannelName,
          description: 'Consejos y reflexiones para tu bienestar',
          importance: Importance.low,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _appointmentsChannelId,
          _appointmentsChannelName,
          description: 'Recordatorios para tus citas programadas',
          importance: Importance.high,
        ),
      );
    }

    _initialized = true;
  }

  Future<void> scheduleMeditationReminder(int hour, int minute) async {
    await _plugin.zonedSchedule(
      1001,
      'Momento de meditar',
      'Dedica unos minutos a tu práctica de meditación diaria 🧘',
      _nextDailyTime(hour, minute),
      _notificationDetails(_meditationChannelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMoodCheckIn(int hour, int minute) async {
    await _plugin.zonedSchedule(
      1002,
      '¿Cómo te sientes hoy?',
      'Tómate un momento para registrar tu estado de ánimo 💭',
      _nextDailyTime(hour, minute),
      _notificationDetails(_moodChannelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleWindDown(int hour, int minute) async {
    await _plugin.zonedSchedule(
      1003,
      'Hora de relajarte',
      'Prepárate para descansar con una sesión de relajación 🌙',
      _nextDailyTime(hour, minute),
      _notificationDetails(_windDownChannelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMotivationalTips(String frequency) async {
    final tips = [
      'Respira profundo. Todo va a estar bien.',
      'Cada día es una nueva oportunidad para crecer.',
      'No estás solo en este camino.',
      'Tu salud mental es tan importante como tu salud física.',
      'Pequeños pasos llevan a grandes cambios.',
      'Date permiso para descansar.',
      'La gratitud transforma lo que tenemos en suficiente.',
    ];

    final randomTip = tips[Random().nextInt(tips.length)];

    await _plugin.zonedSchedule(
      1004,
      'Consejo del día',
      randomTip,
      _nextDailyTime(12, 0),
      _notificationDetails(_tipsChannelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: frequency == 'weekly'
          ? DateTimeComponents.dayOfWeekAndTime
          : DateTimeComponents.time,
    );
  }

  Future<void> scheduleAppointmentReminder(
    int id,
    DateTime appointmentTime,
    int minutesBefore,
    String patientName,
  ) async {
    final reminderTime = appointmentTime.subtract(Duration(minutes: minutesBefore));

    if (reminderTime.isBefore(DateTime.now())) return;

    final tzTime = tz.TZDateTime.from(reminderTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      'Cita próxima',
      'Tienes una cita con $patientName en $minutesBefore minutos 📅',
      tzTime,
      _notificationDetails(_appointmentsChannelId),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAppointmentReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> rescheduleAll(NotificationPreferences prefs) async {
    await _plugin.cancel(1001);
    await _plugin.cancel(1002);
    await _plugin.cancel(1003);
    await _plugin.cancel(1004);

    if (prefs.meditationEnabled) {
      await scheduleMeditationReminder(
        prefs.meditationHour,
        prefs.meditationMinute,
      );
    }
    if (prefs.moodCheckInEnabled) {
      await scheduleMoodCheckIn(
        prefs.moodCheckInHour,
        prefs.moodCheckInMinute,
      );
    }
    if (prefs.windDownEnabled) {
      await scheduleWindDown(prefs.windDownHour, prefs.windDownMinute);
    }
    if (prefs.motivationalTipsEnabled) {
      await scheduleMotivationalTips(prefs.tipsFrequency);
    }
  }

  tz.TZDateTime _nextDailyTime(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  NotificationDetails _notificationDetails(String channelId) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        _channelName(channelId),
        importance: channelId == _appointmentsChannelId
            ? Importance.high
            : Importance.defaultImportance,
        priority: channelId == _appointmentsChannelId
            ? Priority.high
            : Priority.defaultPriority,
        icon: '@mipmap/ic_launcher',
      ),
    );
  }

  String _channelName(String channelId) {
    switch (channelId) {
      case _meditationChannelId:
        return _meditationChannelName;
      case _moodChannelId:
        return _moodChannelName;
      case _windDownChannelId:
        return _windDownChannelName;
      case _tipsChannelId:
        return _tipsChannelName;
      case _appointmentsChannelId:
        return _appointmentsChannelName;
      default:
        return 'Notificaciones';
    }
  }
}
