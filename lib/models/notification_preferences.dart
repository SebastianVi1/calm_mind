class NotificationPreferences {
  final bool meditationEnabled;
  final int meditationHour;
  final int meditationMinute;
  final bool moodCheckInEnabled;
  final int moodCheckInHour;
  final int moodCheckInMinute;
  final bool windDownEnabled;
  final int windDownHour;
  final int windDownMinute;
  final bool motivationalTipsEnabled;
  final String tipsFrequency; // 'daily' | 'weekly'
  final bool appointmentsEnabled;
  final int appointmentAdvanceMinutes; // 15, 30, 60

  const NotificationPreferences({
    this.meditationEnabled = false,
    this.meditationHour = 8,
    this.meditationMinute = 0,
    this.moodCheckInEnabled = false,
    this.moodCheckInHour = 10,
    this.moodCheckInMinute = 0,
    this.windDownEnabled = false,
    this.windDownHour = 21,
    this.windDownMinute = 0,
    this.motivationalTipsEnabled = false,
    this.tipsFrequency = 'daily',
    this.appointmentsEnabled = true,
    this.appointmentAdvanceMinutes = 30,
  });

  Map<String, dynamic> toMap() {
    return {
      'meditationEnabled': meditationEnabled,
      'meditationHour': meditationHour,
      'meditationMinute': meditationMinute,
      'moodCheckInEnabled': moodCheckInEnabled,
      'moodCheckInHour': moodCheckInHour,
      'moodCheckInMinute': moodCheckInMinute,
      'windDownEnabled': windDownEnabled,
      'windDownHour': windDownHour,
      'windDownMinute': windDownMinute,
      'motivationalTipsEnabled': motivationalTipsEnabled,
      'tipsFrequency': tipsFrequency,
      'appointmentsEnabled': appointmentsEnabled,
      'appointmentAdvanceMinutes': appointmentAdvanceMinutes,
    };
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> map) {
    return NotificationPreferences(
      meditationEnabled: map['meditationEnabled'] as bool? ?? false,
      meditationHour: map['meditationHour'] as int? ?? 8,
      meditationMinute: map['meditationMinute'] as int? ?? 0,
      moodCheckInEnabled: map['moodCheckInEnabled'] as bool? ?? false,
      moodCheckInHour: map['moodCheckInHour'] as int? ?? 10,
      moodCheckInMinute: map['moodCheckInMinute'] as int? ?? 0,
      windDownEnabled: map['windDownEnabled'] as bool? ?? false,
      windDownHour: map['windDownHour'] as int? ?? 21,
      windDownMinute: map['windDownMinute'] as int? ?? 0,
      motivationalTipsEnabled: map['motivationalTipsEnabled'] as bool? ?? false,
      tipsFrequency: map['tipsFrequency'] as String? ?? 'daily',
      appointmentsEnabled: map['appointmentsEnabled'] as bool? ?? true,
      appointmentAdvanceMinutes: map['appointmentAdvanceMinutes'] as int? ?? 30,
    );
  }

  NotificationPreferences copyWith({
    bool? meditationEnabled,
    int? meditationHour,
    int? meditationMinute,
    bool? moodCheckInEnabled,
    int? moodCheckInHour,
    int? moodCheckInMinute,
    bool? windDownEnabled,
    int? windDownHour,
    int? windDownMinute,
    bool? motivationalTipsEnabled,
    String? tipsFrequency,
    bool? appointmentsEnabled,
    int? appointmentAdvanceMinutes,
  }) {
    return NotificationPreferences(
      meditationEnabled: meditationEnabled ?? this.meditationEnabled,
      meditationHour: meditationHour ?? this.meditationHour,
      meditationMinute: meditationMinute ?? this.meditationMinute,
      moodCheckInEnabled: moodCheckInEnabled ?? this.moodCheckInEnabled,
      moodCheckInHour: moodCheckInHour ?? this.moodCheckInHour,
      moodCheckInMinute: moodCheckInMinute ?? this.moodCheckInMinute,
      windDownEnabled: windDownEnabled ?? this.windDownEnabled,
      windDownHour: windDownHour ?? this.windDownHour,
      windDownMinute: windDownMinute ?? this.windDownMinute,
      motivationalTipsEnabled:
          motivationalTipsEnabled ?? this.motivationalTipsEnabled,
      tipsFrequency: tipsFrequency ?? this.tipsFrequency,
      appointmentsEnabled: appointmentsEnabled ?? this.appointmentsEnabled,
      appointmentAdvanceMinutes:
          appointmentAdvanceMinutes ?? this.appointmentAdvanceMinutes,
    );
  }
}
