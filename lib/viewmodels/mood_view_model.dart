import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calm_mind/models/mood_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:calm_mind/repositories/mood_repository.dart';
import 'package:calm_mind/services/ai/i_ai_service.dart';
import 'package:uuid/uuid.dart';

class MoodViewModel extends ChangeNotifier {
  final MoodRepository _moodRepository = MoodRepository();
  final userId = FirebaseAuth.instance.currentUser!.uid;
  late List<MoodModel> availableMoods;
  late List<MoodModel> moodHistory = [];

  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _error;

  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;

  MoodViewModel() {
    availableMoods = [
      MoodModel(
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        timestamp: DateTime.now(),
        color: Colors.blue,
      ),
      MoodModel(
        label: 'Neutral',
        lottieAsset: 'assets/animations/neutral_emoji.json',
        timestamp: DateTime.now(),
        color: Colors.green,
      ),
      MoodModel(
        label: 'Enojado',
        lottieAsset: 'assets/animations/angry_emoji.json',
        timestamp: DateTime.now(),
        color: Colors.orangeAccent,
      ),
      MoodModel(
        label: 'Triste',
        lottieAsset: 'assets/animations/sad_emoji.json',
        timestamp: DateTime.now(),
        color: Colors.grey,
      ),
    ];
    _loadDemoData();
  }

  void _loadDemoData() {
    final now = DateTime.now();
    final demoEntries = [
      MoodModel(
        moodId: 'demo1',
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        color: Colors.blue,
        timestamp: now.subtract(const Duration(minutes: 30)),
        note: 'Terminé mi proyecto a tiempo!',
        content: 'Hoy fue un día productivo. Logré terminar todas mis tareas pendientes y me siento genial por ello.',
        aiAnalysis: AiAnalysis(
          sentimentScore: 7,
          summary: 'Día muy positivo con logros personales.',
          tags: ['productividad', 'logro', 'motivación'],
          insights: [
            AiInsight(insight: 'Muestras una actitud positiva hacia el trabajo.', suggestion: 'Continúa estableciendo metas alcanzables.'),
          ],
        ),
      ),
      MoodModel(
        moodId: 'demo2',
        label: 'Neutral',
        lottieAsset: 'assets/animations/neutral_emoji.json',
        color: Colors.green,
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        note: 'Día normal',
        content: 'Un día más de rutina. Nada especial pero tampoco malo.',
      ),
      MoodModel(
        moodId: 'demo3',
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        color: Colors.blue,
        timestamp: now.subtract(const Duration(days: 2, hours: 5)),
        note: 'Salí con amigos',
        content: 'Pasar tiempo con mis amigos siempre me recuerda lo afortunado que soy.',
        aiAnalysis: AiAnalysis(
          sentimentScore: 8,
          summary: 'Momento social positivo que fortalece tu bienestar.',
          tags: ['amistad', 'social', 'felicidad'],
          insights: [
            AiInsight(insight: 'Las conexiones sociales son importantes para ti.', suggestion: 'Programa reuniones regulares con amigos.'),
          ],
        ),
      ),
      MoodModel(
        moodId: 'demo4',
        label: 'Triste',
        lottieAsset: 'assets/animations/sad_emoji.json',
        color: Colors.grey,
        timestamp: now.subtract(const Duration(days: 3, hours: 8)),
        note: 'Me sentí solo',
        content: 'Hoy me sentí un poco bajoneado. Creo que necesito hablar con alguien.',
        aiAnalysis: AiAnalysis(
          sentimentScore: -3,
          summary: 'Momento de reflexión y necesidad de conexión.',
          tags: ['soledad', 'reflexión'],
          insights: [
            AiInsight(insight: 'Reconocer tus emociones es el primer paso.', suggestion: 'Considera hablar con alguien de confianza.'),
          ],
        ),
      ),
      MoodModel(
        moodId: 'demo5',
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        color: Colors.blue,
        timestamp: now.subtract(const Duration(days: 4, hours: 3)),
        content: 'Hice ejercicio hoy y me siento con más energía.',
      ),
      MoodModel(
        moodId: 'demo6',
        label: 'Enojado',
        lottieAsset: 'assets/animations/angry_emoji.json',
        color: Colors.orangeAccent,
        timestamp: now.subtract(const Duration(days: 5, hours: 6)),
        note: 'Problemas en el trabajo',
        content: 'Tuve un desacuerdo con un colega. Necesito manejar mejor mi frustración.',
        aiAnalysis: AiAnalysis(
          sentimentScore: -5,
          summary: 'Conflicto interpersonal que afecta tu estado de ánimo.',
          tags: ['estrés', 'conflicto', 'trabajo'],
          insights: [
            AiInsight(insight: 'El enojo puede ser una señal de necesidades no cubiertas.', suggestion: 'Practica técnicas de respiración antes de reaccionar.'),
          ],
        ),
      ),
      MoodModel(
        moodId: 'demo7',
        label: 'Neutral',
        lottieAsset: 'assets/animations/neutral_emoji.json',
        color: Colors.green,
        timestamp: now.subtract(const Duration(days: 6, hours: 1)),
      ),
      MoodModel(
        moodId: 'demo8',
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        color: Colors.blue,
        timestamp: now.subtract(const Duration(days: 7, hours: 4)),
        note: 'Primera vez usando la app',
        content: 'Empecé a usar CalmMind para mejorar mi bienestar emocional. Espero que me ayude.',
      ),
      MoodModel(
        moodId: 'demo9',
        label: 'Feliz',
        lottieAsset: 'assets/animations/happy_emoji.json',
        color: Colors.blue,
        timestamp: now.subtract(const Duration(days: 8, hours: 2)),
        content: 'Hoy desperté de buen humor y eso marcó mi día.',
      ),
      MoodModel(
        moodId: 'demo10',
        label: 'Triste',
        lottieAsset: 'assets/animations/sad_emoji.json',
        color: Colors.grey,
        timestamp: now.subtract(const Duration(days: 9, hours: 7)),
        note: 'No pude dormir bien',
        content: 'La falta de sueño me afectó todo el día. Necesito mejorar mis hábitos de descanso.',
      ),
    ];
    moodHistory = demoEntries;
  }

  MoodModel? _selectedMood;
  MoodModel? get selectedMood => _selectedMood;

  TextEditingController noteController = TextEditingController();

  void selectMood(MoodModel mood) {
    _selectedMood = mood;
    notifyListeners();
  }

  void saveMoodEntry({String? content}) {
    if (_selectedMood == null) return;
    Uuid uuid = const Uuid();
    final moodWithCurrentTime = MoodModel(
      moodId: uuid.v4(),
      label: _selectedMood!.label,
      lottieAsset: _selectedMood!.lottieAsset,
      color: _selectedMood!.color,
      timestamp: DateTime.now(),
      note: noteController.text.isNotEmpty ? noteController.text : null,
      content: content,
    );
    _moodRepository.registerMood(userId, moodWithCurrentTime);
    moodHistory.add(moodWithCurrentTime);
    notifyListeners();
    noteController.clear();
    _selectedMood = null;
    notifyListeners();
  }

  Future<MoodModel> saveMoodEntryAsync({String? content, String? moodLabel}) async {
    Uuid uuid = const Uuid();
    final mood = _selectedMood ?? availableMoods.firstWhere(
      (m) => m.label.toLowerCase() == moodLabel?.toLowerCase(),
      orElse: () => availableMoods[0],
    );

    final moodWithCurrentTime = MoodModel(
      moodId: uuid.v4(),
      label: mood.label,
      lottieAsset: mood.lottieAsset,
      color: mood.color,
      timestamp: DateTime.now(),
      note: noteController.text.isNotEmpty ? noteController.text : null,
      content: content,
    );
    await _moodRepository.registerMood(userId, moodWithCurrentTime);
    moodHistory.add(moodWithCurrentTime);
    noteController.clear();
    _selectedMood = null;
    notifyListeners();
    return moodWithCurrentTime;
  }

  void resetMoodSelection() {
    _selectedMood = null;
    noteController.clear();
    notifyListeners();
  }

  bool _firstTime = false;
  Future<List<MoodModel>> fetchMoodHistory(String userId) async {
    try {
      if (!_firstTime) {
        setLoading(true);
        await Future.delayed(const Duration(seconds: 1));
        _firstTime = true;
      }
      final fetchedMoodHistory = await _moodRepository.getMoodHistory(userId);
      moodHistory = fetchedMoodHistory;
      setLoading(false);
      notifyListeners();
      return moodHistory;
    } catch (e) {
      return [];
    }
  }

  List<MoodModel> getMoodsForDate(DateTime date) {
    return moodHistory.where((mood) {
      final moodDate = mood.timestamp;
      return moodDate.year == date.year &&
          moodDate.month == date.month &&
          moodDate.day == date.day;
    }).toList();
  }

  List<MoodModel> getAllMoodHistory() {
    return List.from(moodHistory.reversed);
  }

  List<MoodModel> get entriesThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return moodHistory.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }

  int get streakDays {
    if (moodHistory.isEmpty) return 0;

    final dates = moodHistory
        .map((e) => DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day))
        .toSet()
        .toList();
    dates.sort((a, b) => b.compareTo(a));

    int streak = 0;
    DateTime? lastDate;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    for (final date in dates) {
      if (lastDate == null) {
        final diff = todayDate.difference(date).inDays;
        if (diff > 1) break;
        streak = 1;
        lastDate = date;
      } else {
        final diff = lastDate.difference(date).inDays;
        if (diff == 1) {
          streak++;
          lastDate = date;
        } else if (diff > 1) {
          break;
        }
      }
    }

    return streak;
  }

  Future<void> analyzeMoodEntry(String moodId, IAIService aiService) async {
    _isAnalyzing = true;
    _error = null;
    notifyListeners();

    try {
      final entry = moodHistory.firstWhere((m) => m.moodId == moodId);
      if (entry.content == null || entry.content!.isEmpty) {
        _isAnalyzing = false;
        notifyListeners();
        return;
      }

      final prompt = '''
Analiza la siguiente entrada de diario de salud mental y devuelve un JSON con:
1. sentimentScore: un número del -10 al 10 (-10 muy negativo, 0 neutral, 10 muy positivo)
2. insights: lista de objetos con {insight, suggestion}
3. tags: lista de tags relevantes (max 5)
4. summary: un resumen breve y empático (max 2 líneas)

Entrada: "${entry.content}"

Estado de ánimo: ${entry.label}

Devuelve SOLO JSON válido con esta estructura:
{
  "sentimentScore": 0,
  "insights": [{"insight": "...", "suggestion": "..."}],
  "tags": ["tag1", "tag2"],
  "summary": "..."
}
''';

      final response = await aiService.sendMessage(prompt);

      String jsonStr = response;
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        jsonStr = response.substring(jsonStart, jsonEnd + 1);
      }

      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      final sentimentScore = parsed['sentimentScore'] as int? ?? 0;
      final summary = parsed['summary'] as String? ?? '';

      final insightsList = (parsed['insights'] as List<dynamic>?)
              ?.map((i) => AiInsight(
                    insight: i['insight'] ?? '',
                    suggestion: i['suggestion'] ?? '',
                  ))
              .toList() ??
          [];

      final tags = (parsed['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      final analysis = AiAnalysis(
        sentimentScore: sentimentScore,
        summary: summary,
        tags: tags,
        insights: insightsList,
      );

      await _moodRepository.updateAiAnalysis(userId, moodId, analysis);

      final index = moodHistory.indexWhere((m) => m.moodId == moodId);
      if (index >= 0) {
        moodHistory[index] = moodHistory[index].copyWith(aiAnalysis: analysis);
      }

      _error = null;
    } catch (e) {
      _error = 'Error al analizar la entrada: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<String> generateWeeklyInsight(IAIService aiService) async {
    try {
      final weekEntries = entriesThisWeek;
      if (weekEntries.isEmpty) {
        return 'Aún no hay entradas esta semana. ¡Comienza a registrar tus emociones!';
      }

      final entriesText = weekEntries.map((e) {
        final notePart = e.note != null && e.note!.isNotEmpty ? '\nNota: ${e.note}' : '';
        final contentPart = e.content != null && e.content!.isNotEmpty ? '\nDiario: ${e.content}' : '';
        return '${e.label} (${e.timestamp.day}/${e.timestamp.month})$notePart$contentPart';
      }).join('\n---\n');

      final prompt = '''
Basándote en estas entradas de emociones de la semana, genera un insight semanal breve y empático (máximo 3 párrafos):
- Identifica patrones emocionales
- Menciona logros o progresos
- Sugiere un área de enfoque para la próxima semana

Entradas:
$entriesText

Responde de forma cálida y profesional.
''';

      return await aiService.sendMessage(prompt);
    } catch (e) {
      return 'No se pudo generar el insight semanal.';
    }
  }

  List<FlSpot> getMoodChartData() {
    Map<int, List<MoodModel>> moodsByDay = {};

    for (var mood in moodHistory) {
      final day = mood.timestamp.day;
      moodsByDay.putIfAbsent(day, () => []).add(mood);
    }

    List<FlSpot> spots = [];
    moodsByDay.forEach((day, moods) {
      double sum = 0;
      for (var mood in moods) {
        switch (mood.label.toLowerCase()) {
          case 'feliz':
            sum += 4.0;
            break;
          case 'neutral':
            sum += 3.0;
            break;
          case 'triste':
            sum += 1.0;
            break;
          case 'enojado':
            sum += 2.0;
            break;
          default:
            sum += 3.0;
        }
      }
      double average = sum / moods.length;
      spots.add(FlSpot(day.toDouble(), average));
    });

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  String getMoodTrend() {
    if (moodHistory.length < 2) return "Necesitas más datos";

    final recentMoods = moodHistory.take(5).toList();
    double sum = 0;
    for (var mood in recentMoods) {
      switch (mood.label.toLowerCase()) {
        case 'feliz':
          sum += 5;
        case 'neutral':
          sum += 3;
        case 'triste':
          sum += 1;
        case 'enojado':
          sum += 2;
      }
    }
    double average = sum / recentMoods.length;

    if (average > 3.5) return "Tendencia positiva 📈";
    if (average < 2.5) return "Tendencia negativa 📉";
    return "Tendencia irregular ↔️";
  }

  List<MoodModel> filterMoods(String filter) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekAgo = today.subtract(const Duration(days: 7));

    switch (filter) {
      case 'hoy':
        return moodHistory.where((mood) {
          final moodDate = mood.timestamp;
          return moodDate.year == today.year &&
              moodDate.month == today.month &&
              moodDate.day == today.day;
        }).toList().reversed.toList();

      case 'semanal':
        return moodHistory.where((mood) {
          return mood.timestamp.isAfter(weekAgo) ||
              mood.timestamp.isAtSameMomentAs(weekAgo);
        }).toList().reversed.toList();

      case 'todos':
        return List.from(moodHistory);

      default:
        return List.from(moodHistory.reversed);
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void deleteMood(MoodModel mood) {
    _moodRepository.deleteMood(userId, mood);
    moodHistory.remove(mood);
    notifyListeners();
  }

  int _touchedIndex = -1;
  int get tochedIndex => _touchedIndex;

  void setTouchedIndex(int newValue) {
    _touchedIndex = newValue;
    notifyListeners();
  }

  Map<String, int> logicPieChart(MoodViewModel viewModel) {
    List<MoodModel> currentHistory = getAllMoodHistory();
    Map<String, int> moodCount;

    int happyCounter = 0;
    int neutralCounter = 0;
    int angryCounter = 0;
    int sadCounter = 0;

    if (currentHistory.isEmpty) {
      return {};
    }

    for (MoodModel mood in currentHistory) {
      switch (mood.label) {
        case "Feliz":
          happyCounter++;
        case "Neutral":
          neutralCounter++;
        case "Enojado":
          angryCounter++;
        case "Triste":
          sadCounter++;
      }
    }

    moodCount = {
      'happy': happyCounter,
      'neutral': neutralCounter,
      'angry': angryCounter,
      'sad': sadCounter,
    };

    return moodCount;
  }

  double porcentage(String emotion) {
    double porcentage = 0;
    int total = 0;
    var map = logicPieChart(this);

    if (map.isEmpty) {
      return 0;
    }

    for (int value in map.values) {
      total += value;
    }

    if (total == 0) {
      return 0;
    }

    int current = map[emotion] ?? 0;
    porcentage = ((current * 100) / total);
    return porcentage;
  }
}
