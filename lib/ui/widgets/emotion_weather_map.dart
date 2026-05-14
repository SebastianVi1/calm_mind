import 'package:flutter/material.dart';
import 'package:calm_mind/models/mood_model.dart';
import 'package:calm_mind/repositories/mood_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmotionWeatherMap extends StatefulWidget {
  const EmotionWeatherMap({super.key});

  @override
  State<EmotionWeatherMap> createState() => _EmotionWeatherMapState();
}

class _EmotionWeatherMapState extends State<EmotionWeatherMap> {
  final MoodRepository _moodRepository = MoodRepository();
  Map<DateTime, MoodModel> _moodData = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMoodData();
  }

  Future<void> _loadMoodData() async {
    setState(() => _isLoading = true);

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final moods = await _moodRepository.getMoodHistory(userId);
        _moodData = {};
        for (final mood in moods) {
          final date = DateTime(mood.timestamp.year, mood.timestamp.month, mood.timestamp.day);
          if (!_moodData.containsKey(date) || mood.timestamp.isAfter(_moodData[date]!.timestamp)) {
            _moodData[date] = mood;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading mood data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.cloud, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Mapa del Clima Emocional',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Tu mes visto como el clima de tus emociones',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              _buildWeatherCalendar(context),
            const SizedBox(height: 12),
            _buildWeatherLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCalendar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final cellSize = (availableWidth - 24) / 7;
        final cellHeight = cellSize * 1.1;
        final dayFontSize = cellSize * 0.3;
        final iconFontSize = cellSize * 0.45;

        final now = DateTime.now();
        final firstDayOfMonth = DateTime(now.year, now.month, 1);
        final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
        final daysInMonth = lastDayOfMonth.day;
        final firstWeekday = firstDayOfMonth.weekday;

        final dayHeaders = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

        return SingleChildScrollView(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: dayHeaders.map((d) {
                  return SizedBox(
                    width: cellSize,
                    child: Text(
                      d,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: dayFontSize,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  for (int i = 0; i < (firstWeekday - 1); i++)
                    SizedBox(width: cellSize, height: cellHeight),
                  for (int day = 1; day <= daysInMonth; day++)
                    _buildWeatherDay(
                      context,
                      DateTime(now.year, now.month, day),
                      day,
                      cellSize,
                      cellHeight,
                      dayFontSize,
                      iconFontSize,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeatherDay(
    BuildContext context,
    DateTime date,
    int day,
    double cellSize,
    double cellHeight,
    double dayFontSize,
    double iconFontSize,
  ) {
    final mood = _moodData[date];
    final isToday = date.day == DateTime.now().day &&
        date.month == DateTime.now().month &&
        date.year == DateTime.now().year;

    final weatherInfo = _getWeatherForMood(mood);

    return GestureDetector(
      onTap: mood != null ? () => _showDayDetail(context, date, mood) : null,
      child: Container(
        width: cellSize,
        height: cellHeight,
        decoration: BoxDecoration(
          color: isToday
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)
              : mood != null
                  ? weatherInfo.backgroundColor
                  : Colors.transparent,
          borderRadius: BorderRadius.circular(cellSize * 0.15),
          border: isToday
              ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2)
              : null,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: Text(
                '$day',
                style: TextStyle(
                  fontSize: dayFontSize,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  color: mood != null ? weatherInfo.textColor : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ),
            if (mood != null)
              Positioned(
                bottom: 2,
                left: 0,
                right: 0,
                child: Text(
                  weatherInfo.icon,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: iconFontSize * 0.8,
                    height: 1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  WeatherInfo _getWeatherForMood(MoodModel? mood) {
    if (mood == null) {
      return WeatherInfo(icon: '', backgroundColor: Colors.transparent, textColor: Colors.grey);
    }

    final label = mood.label.toLowerCase();
    if (label.contains('feliz') || label.contains('happy')) {
      return WeatherInfo(
        icon: '☀️',
        backgroundColor: const Color(0xFFFFF9C4),
        textColor: const Color(0xFFF57F17),
      );
    } else if (label.contains('neutral')) {
      return WeatherInfo(
        icon: '⛅',
        backgroundColor: const Color(0xFFE0E0E0),
        textColor: const Color(0xFF616161),
      );
    } else if (label.contains('enoj') || label.contains('angry')) {
      return WeatherInfo(
        icon: '⛈️',
        backgroundColor: const Color(0xFFEF9A9A),
        textColor: const Color(0xFFC62828),
      );
    } else if (label.contains('triste') || label.contains('sad')) {
      return WeatherInfo(
        icon: '🌧️',
        backgroundColor: const Color(0xFFBBDEFB),
        textColor: const Color(0xFF1565C0),
      );
    } else {
      return WeatherInfo(
        icon: '🌤️',
        backgroundColor: const Color(0xFFE8F5E9),
        textColor: const Color(0xFF2E7D32),
      );
    }
  }

  Widget _buildWeatherLegend(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 6,
      children: [
        _LegendItem(icon: '☀️', label: 'Feliz', color: const Color(0xFFFFF9C4)),
        _LegendItem(icon: '⛅', label: 'Neutral', color: const Color(0xFFE0E0E0)),
        _LegendItem(icon: '🌧️', label: 'Triste', color: const Color(0xFFBBDEFB)),
        _LegendItem(icon: '⛈️', label: 'Enojado', color: const Color(0xFFEF9A9A)),
      ],
    );
  }

  void _showDayDetail(BuildContext context, DateTime date, MoodModel mood) {
    final weatherInfo = _getWeatherForMood(mood);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  weatherInfo.icon,
                  style: const TextStyle(fontSize: 48),
                ),
                const SizedBox(height: 16),
                Text(
                  '${date.day}/${date.month}/${date.year}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: weatherInfo.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mood.label,
                    style: TextStyle(
                      color: weatherInfo.textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (mood.note != null && mood.note!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    mood.note!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}

class WeatherInfo {
  final String icon;
  final Color backgroundColor;
  final Color textColor;

  WeatherInfo({
    required this.icon,
    required this.backgroundColor,
    required this.textColor,
  });
}

class _LegendItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 10)),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
