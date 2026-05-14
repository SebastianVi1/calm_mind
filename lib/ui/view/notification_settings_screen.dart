import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/viewmodels/notification_view_model.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
          ),
        ),
        child: SafeArea(
          child: Consumer<NotificationViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.loading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                );
              }

              return Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildSettingsList(viewModel)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
      child: Row(
        children: [
          IconButton(
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notificaciones',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Configura tus recordatorios',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(NotificationViewModel viewModel) {
    final prefs = viewModel.prefs;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Meditation reminder
        _buildSection(
          icon: Icons.self_improvement_rounded,
          color: const Color(0xFF9D4EDD),
          title: 'Recordatorio de meditación',
          subtitle: 'Recibe un recordatorio diario para tu sesión de meditación',
          enabled: prefs.meditationEnabled,
          onToggle: (v) => viewModel.toggleMeditation(v),
          trailing: prefs.meditationEnabled
              ? GestureDetector(
                  onTap: () => _pickTime(
                    context,
                    TimeOfDay(
                      hour: prefs.meditationHour,
                      minute: prefs.meditationMinute,
                    ),
                    (t) => viewModel.setMeditationTime(t.hour, t.minute),
                  ),
                  child: _buildTimeChip(
                    prefs.meditationHour,
                    prefs.meditationMinute,
                  ),
                )
              : null,
        ),

        const SizedBox(height: 12),

        // Mood check-in
        _buildSection(
          icon: Icons.mood_rounded,
          color: const Color(0xFFFF9100),
          title: 'Registro de ánimo',
          subtitle: 'Recuerda registrar cómo te sientes cada día',
          enabled: prefs.moodCheckInEnabled,
          onToggle: (v) => viewModel.toggleMoodCheckIn(v),
          trailing: prefs.moodCheckInEnabled
              ? GestureDetector(
                  onTap: () => _pickTime(
                    context,
                    TimeOfDay(
                      hour: prefs.moodCheckInHour,
                      minute: prefs.moodCheckInMinute,
                    ),
                    (t) => viewModel.setMoodCheckInTime(t.hour, t.minute),
                  ),
                  child: _buildTimeChip(
                    prefs.moodCheckInHour,
                    prefs.moodCheckInMinute,
                  ),
                )
              : null,
        ),

        const SizedBox(height: 12),

        // Evening wind-down
        _buildSection(
          icon: Icons.nightlight_round_rounded,
          color: const Color(0xFF1EAE98),
          title: 'Relajación nocturna',
          subtitle: 'Aviso para comenzar tu rutina de descanso',
          enabled: prefs.windDownEnabled,
          onToggle: (v) => viewModel.toggleWindDown(v),
          trailing: prefs.windDownEnabled
              ? GestureDetector(
                  onTap: () => _pickTime(
                    context,
                    TimeOfDay(
                      hour: prefs.windDownHour,
                      minute: prefs.windDownMinute,
                    ),
                    (t) => viewModel.setWindDownTime(t.hour, t.minute),
                  ),
                  child: _buildTimeChip(
                    prefs.windDownHour,
                    prefs.windDownMinute,
                  ),
                )
              : null,
        ),

        const SizedBox(height: 12),

        // Motivational tips
        _buildSection(
          icon: Icons.lightbulb_outline_rounded,
          color: const Color(0xFFF5C518),
          title: 'Consejos motivacionales',
          subtitle: 'Recibe consejos y reflexiones para tu bienestar',
          enabled: prefs.motivationalTipsEnabled,
          onToggle: (v) => viewModel.toggleMotivationalTips(v),
          trailing: prefs.motivationalTipsEnabled
              ? _buildFrequencyDropdown(
                  prefs.tipsFrequency,
                  (f) => viewModel.setTipsFrequency(f),
                )
              : null,
        ),

        const SizedBox(height: 12),

        // Appointment reminders
        _buildSection(
          icon: Icons.calendar_month_rounded,
          color: const Color(0xFF4A90D9),
          title: 'Recordatorios de citas',
          subtitle: 'Notificaciones antes de tus citas programadas',
          enabled: prefs.appointmentsEnabled,
          onToggle: (v) => viewModel.toggleAppointments(v),
          trailing: prefs.appointmentsEnabled
              ? _buildAdvanceDropdown(
                  prefs.appointmentAdvanceMinutes,
                  (m) => viewModel.setAppointmentAdvance(m),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool enabled,
    required ValueChanged<bool> onToggle,
    Widget? trailing,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: color.withValues(alpha: 0.15),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: enabled,
                    onChanged: onToggle,
                    activeTrackColor: color.withValues(alpha: 0.5),
                    activeThumbColor: color,
                  ),
                ],
              ),
              if (enabled && trailing != null) ...[
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: trailing,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeChip(int hour, int minute) {
    final hourStr = hour.toString().padLeft(2, '0');
    final minStr = minute.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.access_time_rounded, color: Colors.white54, size: 16),
          const SizedBox(width: 6),
          Text(
            '$hourStr:$minStr',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, color: Colors.white54, size: 18),
        ],
      ),
    );
  }

  Widget _buildFrequencyDropdown(
    String current,
    ValueChanged<String> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: current,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
          items: const [
            DropdownMenuItem(
              value: 'daily',
              child: Text('Cada día'),
            ),
            DropdownMenuItem(
              value: 'weekly',
              child: Text('Cada semana'),
            ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildAdvanceDropdown(
    int current,
    ValueChanged<int> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: current,
          dropdownColor: const Color(0xFF1A1A2E),
          style: const TextStyle(color: Colors.white, fontSize: 13),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
          items: const [
            DropdownMenuItem(value: 15, child: Text('15 min antes')),
            DropdownMenuItem(value: 30, child: Text('30 min antes')),
            DropdownMenuItem(value: 60, child: Text('1 hora antes')),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Future<void> _pickTime(
    BuildContext context,
    TimeOfDay initial,
    ValueChanged<TimeOfDay> onPicked,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF9D4EDD),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}
