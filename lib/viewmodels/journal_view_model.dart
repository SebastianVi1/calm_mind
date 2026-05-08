import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:calm_mind/models/journal_model.dart';
import 'package:calm_mind/repositories/journal_repository.dart';
import 'package:calm_mind/services/ai/gemini_service.dart';

class JournalViewModel extends ChangeNotifier {
  final JournalRepository _repository = JournalRepository();
  final GeminiService _aiService = GeminiService();

  List<JournalEntry> _entries = [];
  bool _isLoading = false;
  bool _isAnalyzing = false;
  String? _error;
  JournalEntry? _selectedEntry;

  List<JournalEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  bool get isAnalyzing => _isAnalyzing;
  String? get error => _error;
  JournalEntry? get selectedEntry => _selectedEntry;

  List<JournalEntry> get entriesThisWeek {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return _entries.where((e) => e.timestamp.isAfter(weekAgo)).toList();
  }

  Map<String, int> get moodDistribution {
    final distribution = <String, int>{};
    for (final entry in _entries) {
      if (entry.moodLabel != null) {
        distribution[entry.moodLabel!] = (distribution[entry.moodLabel!] ?? 0) + 1;
      }
    }
    return distribution;
  }

  int get streakDays {
    if (_entries.isEmpty) return 0;

    final dates = _entries
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

  JournalViewModel() {
    loadEntries();
  }

  Future<void> loadEntries() async {
    _isLoading = true;
    notifyListeners();

    try {
      _entries = await _repository.getEntries();
      _error = null;
    } catch (e) {
      _error = 'Error al cargar las entradas: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<JournalEntry> createEntry(String content, {String? moodLabel}) async {
    try {
      final entry = JournalEntry(
        id: const Uuid().v4(),
        content: content,
        timestamp: DateTime.now(),
        moodLabel: moodLabel,
      );

      await _repository.saveEntry(entry);
      _entries.insert(0, entry);
      notifyListeners();

      return entry;
    } catch (e) {
      _error = 'Error al crear la entrada: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> analyzeEntry(JournalEntry entry) async {
    _isAnalyzing = true;
    notifyListeners();

    try {
      final prompt = '''
Analiza la siguiente entrada de diario de salud mental y devuelve un JSON con:
1. sentimentScore: un número del -10 al 10 (-10 muy negativo, 0 neutral, 10 muy positivo)
2. insights: lista de objetos con {insight, distortionType, suggestion}
   - distortionType puede ser: CATASTROPHIZING, BLACK_AND_WHITE_THINKING, OVERGENERALIZATION, MIND_READING, PERSONALIZATION, EMOTIONAL_REASONING, SHOULD_STATEMENTS, LABELING, NONE
3. tags: lista de tags relevantes (max 5)
4. summary: un resumen breve y empático (max 2 líneas)

Entrada: "${entry.content}"

Devuelve SOLO JSON válido con esta estructura:
{
  "sentimentScore": 0,
  "insights": [{"insight": "...", "distortionType": "NONE", "suggestion": "..."}],
  "tags": ["tag1", "tag2"],
  "summary": "..."
}
''';

      final response = await _aiService.sendMessage(prompt);

      String jsonStr = response;
      final jsonStart = response.indexOf('{');
      final jsonEnd = response.lastIndexOf('}');
      if (jsonStart >= 0 && jsonEnd > jsonStart) {
        jsonStr = response.substring(jsonStart, jsonEnd + 1);
      }

      final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;

      final sentimentScore = parsed['sentimentScore'] as int?;
      final summary = parsed['summary'] as String? ?? '';

      final insightsList = (parsed['insights'] as List<dynamic>?)
              ?.map((i) => JournalInsight.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [];

      final tags = (parsed['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [];

      await _repository.updateEntryAnalysis(entry.id, summary, insightsList, sentimentScore);

      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index >= 0) {
        _entries[index] = JournalEntry(
          id: entry.id,
          content: entry.content,
          timestamp: entry.timestamp,
          moodLabel: entry.moodLabel,
          aiAnalysis: summary,
          insights: insightsList,
          tags: tags,
          sentimentScore: sentimentScore,
        );
      }

      _error = null;
    } catch (e) {
      _error = 'Error al analizar la entrada: $e';
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      await _repository.deleteEntry(entryId);
      _entries.removeWhere((e) => e.id == entryId);
      notifyListeners();
    } catch (e) {
      _error = 'Error al eliminar la entrada: $e';
      notifyListeners();
    }
  }

  Future<String> generateWeeklyInsight() async {
    try {
      if (entriesThisWeek.isEmpty) {
        return 'Aún no hay entradas esta semana. ¡Comienza a escribir tu diario!';
      }

      final entriesText = entriesThisWeek.map((e) => e.content).join('\n---\n');

      final prompt = '''
Basándote en estas entradas de diario de la semana, genera un insight semanal breve y empático (máximo 3 párrafos):
- Identifica patrones emocionales
- Menciona logros o progresos
- Sugiere un área de enfoque para la próxima semana

Entradas:
$entriesText

Responde de forma cálida y profesional.
''';

      return await _aiService.sendMessage(prompt);
    } catch (e) {
      return 'No se pudo generar el insight semanal.';
    }
  }

  void selectEntry(JournalEntry entry) {
    _selectedEntry = entry;
    notifyListeners();
  }

  void clearSelection() {
    _selectedEntry = null;
    notifyListeners();
  }
}
