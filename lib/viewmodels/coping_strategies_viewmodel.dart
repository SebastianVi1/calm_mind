import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:calm_mind/models/coping_strategy_model.dart';

class CopingStrategiesViewModel extends ChangeNotifier {
  List<CopingStrategy> _strategies = [];
  List<CopingSession> _sessions = [];
  bool _isLoading = false;
  String? _currentMood;

  List<CopingStrategy> get strategies => _strategies;
  List<CopingSession> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get currentMood => _currentMood;

  List<CopingStrategy> get recommendedStrategies {
    if (_currentMood == null || _currentMood!.isEmpty) return _strategies.take(6).toList();

    return _strategies
        .where((s) => s.forMoods.contains(_currentMood!.toLowerCase()))
        .toList()
      ..sort((a, b) {
        final aUsed = _sessions.where((s) => s.strategyId == a.id).length;
        final bUsed = _sessions.where((s) => s.strategyId == b.id).length;
        return aUsed.compareTo(bUsed);
      });
  }

  List<CopingStrategy> getStrategiesByType(CopingStrategyType type) {
    return _strategies.where((s) => s.type == type).toList();
  }

  int get totalSessions => _sessions.length;
  int get completedSessions => _sessions.where((s) => s.isCompleted).length;

  CopingStrategiesViewModel() {
    _initializeStrategies();
    _loadSessions();
  }

  void _initializeStrategies() {
    _strategies = [
      CopingStrategy(
        id: '54321_grounding',
        title: 'Tcnica 5-4-3-2-1',
        description: 'Ancla tus sentidos al momento presente',
        type: CopingStrategyType.GROUNDING,
        icon: '🌍',
        durationMinutes: 5,
        steps: [
          'Nombra 5 cosas que puedes VER ahora mismo',
          'Nombra 4 cosas que puedes TOCAR',
          'Nombra 3 cosas que puedes OÍR',
          'Nombra 2 cosas que puedes OLER',
          'Nombra 1 cosa que puedes SABOREAR',
        ],
        forMoods: ['ansioso', 'triste', 'enojado'],
      ),
      CopingStrategy(
        id: 'box_breathing',
        title: 'Respiración en Caja',
        description: 'Inhala, mantén, exhala, mantén - 4 segundos cada uno',
        type: CopingStrategyType.BREATHING,
        icon: '🫁',
        durationMinutes: 3,
        steps: [
          'Inhala lentamente por la nariz contando hasta 4',
          'Mantén el aire contando hasta 4',
          'Exhala lentamente por la boca contando hasta 4',
          'Mantén sin aire contando hasta 4',
          'Repite el ciclo 4 veces',
        ],
        forMoods: ['ansioso', 'enojado'],
      ),
      CopingStrategy(
        id: 'thought_record',
        title: 'Registro de Pensamientos',
        description: 'Identifica y reformula pensamientos negativos',
        type: CopingStrategyType.COGNITIVE_REFRAMING,
        icon: '📝',
        durationMinutes: 10,
        steps: [
          'Escribe la situación que te molesta',
          'Identifica el pensamiento automático',
          'Qué evidencia tienes a favor?',
          'Qué evidencia tienes en contra?',
          'Escribe un pensamiento alternativo más equilibrado',
        ],
        forMoods: ['triste', 'ansioso'],
      ),
      CopingStrategy(
        id: 'body_scan',
        title: 'Escaneo Corporal',
        description: 'Relaja progresivamente cada parte de tu cuerpo',
        type: CopingStrategyType.PROGRESSIVE_RELAXATION,
        icon: '🧘',
        durationMinutes: 10,
        steps: [
          'Cierra los ojos y respira profundamente',
          'Concéntrate en tus pies - tensa y relaja',
          'Sube a las piernas - tensa y relaja',
          'Concéntrate en el abdomen - respira profundo',
          'Tensa y relaja los hombros y brazos',
          'Relaja la mandíbula y la frente',
        ],
        forMoods: ['ansioso', 'enojado', 'triste'],
      ),
      CopingStrategy(
        id: 'mindful_walking',
        title: 'Caminata Consciente',
        description: 'Camina prestando atención a cada paso',
        type: CopingStrategyType.MINDFULNESS,
        icon: '🚶',
        durationMinutes: 15,
        steps: [
          'Camina a un ritmo cómodo',
          'Siente el contacto de tus pies con el suelo',
          'Nota el movimiento de tus piernas',
          'Observa tu entorno sin juzgar',
          'Si tu mente divaga, vuelve a tus pasos',
        ],
        forMoods: ['ansioso', 'triste'],
      ),
      CopingStrategy(
        id: 'ice_cube',
        title: 'Técnica del Hielo',
        description: 'Usa el frío para anclarte al presente',
        type: CopingStrategyType.GROUNDING,
        icon: '🧊',
        durationMinutes: 2,
        steps: [
          'Toma un cubo de hielo en tu mano',
          'Concéntrate en la sensación de frío',
          'Nota cómo cambia la temperatura',
          'Observa cómo se derrite',
          'Respira profundamente mientras sostienes el hielo',
        ],
        forMoods: ['ansioso', 'enojado'],
      ),
      CopingStrategy(
        id: 'gratitude_list',
        title: 'Lista de Gratitud',
        description: 'Escribe 5 cosas por las que estás agradecido',
        type: CopingStrategyType.CREATIVE,
        icon: '🙏',
        durationMinutes: 5,
        steps: [
          'Piensa en algo pequeño que te hizo sonreír hoy',
          'Piensa en una persona que aprecias',
          'Piensa en algo que tu cuerpo te permite hacer',
          'Piensa en un lugar donde te sientes en paz',
          'Piensa en algo que esperas con ilusión',
        ],
        forMoods: ['triste', 'neutral'],
      ),
      CopingStrategy(
        id: 'progressive_muscle',
        title: 'Relajación Muscular Progresiva',
        description: 'Tensa y relaja cada grupo muscular',
        type: CopingStrategyType.PROGRESSIVE_RELAXATION,
        icon: '💪',
        durationMinutes: 15,
        steps: [
          'Tensa los pies durante 5 segundos, relaja',
          'Tensa las pantorrillas, relaja',
          'Tensa los muslos, relaja',
          'Tensa el abdomen, relaja',
          'Tensa las manos y brazos, relaja',
          'Tensa los hombros, relaja',
          'Tensa la cara, relaja completamente',
        ],
        forMoods: ['ansioso', 'enojado'],
      ),
      CopingStrategy(
        id: 'safe_place',
        title: 'Lugar Seguro',
        description: 'Visualiza un lugar donde te sientes completamente seguro',
        type: CopingStrategyType.MINDFULNESS,
        icon: '🏠',
        durationMinutes: 10,
        steps: [
          'Cierra los ojos y respira profundamente',
          'Imagina un lugar real o imaginario donde te sientes seguro',
          'Nota los colores y formas a tu alrededor',
          'Escucha los sonidos de este lugar',
          'Siente las texturas y temperaturas',
          'Permanece aquí todo el tiempo que necesites',
        ],
        forMoods: ['ansioso', 'triste', 'enojado'],
      ),
      CopingStrategy(
        id: 'call_friend',
        title: 'Conecta con Alguien',
        description: 'Llama o escribe a alguien de confianza',
        type: CopingStrategyType.SOCIAL,
        icon: '📞',
        durationMinutes: 15,
        steps: [
          'Piensa en alguien con quien te sientes cómodo',
          'Envía un mensaje o haz una llamada',
          'No necesitas explicar todo, solo conecta',
          'Pregunta cómo están ellos también',
          'Agradece la conexión',
        ],
        forMoods: ['triste', 'neutral'],
      ),
      CopingStrategy(
        id: 'jumping_jacks',
        title: 'Ejercicio Rápido',
        description: '20 jumping jacks para liberar energía',
        type: CopingStrategyType.PHYSICAL,
        icon: '🏃',
        durationMinutes: 3,
        steps: [
          'Párate con los pies juntos',
          'Salta abriendo piernas y brazos',
          'Vuelve a la posición inicial',
          'Repite 20 veces',
          'Nota cómo cambia tu energía',
        ],
        forMoods: ['enojado', 'ansioso'],
      ),
      CopingStrategy(
        id: 'draw_emotions',
        title: 'Dibuja tus Emociones',
        description: 'Expresa lo que sientes a través del dibujo',
        type: CopingStrategyType.CREATIVE,
        icon: '🎨',
        durationMinutes: 10,
        steps: [
          'Toma papel y lápiz/colores',
          'No pienses, solo deja que tu mano se mueva',
          'Usa colores que representen tus emociones',
          'No juzgues el resultado',
          'Observa lo que creaste sin criticar',
        ],
        forMoods: ['triste', 'enojado', 'ansioso'],
      ),
    ];
    notifyListeners();
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList('coping_sessions') ?? [];
      _sessions = sessionsJson
          .map((s) => CopingSession.fromJson(jsonDecode(s)))
          .toList();
      _sessions.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading coping sessions: $e');
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions.map((s) => jsonEncode(s.toJson())).toList();
      await prefs.setStringList('coping_sessions', sessionsJson);
    } catch (e) {
      debugPrint('Error saving coping sessions: $e');
    }
  }

  Future<void> startSession(String strategyId, {String? moodBefore}) async {
    final strategy = _strategies.firstWhere((s) => s.id == strategyId);
    final session = CopingSession(
      strategyId: strategyId,
      timestamp: DateTime.now(),
      completedSteps: 0,
      totalSteps: strategy.steps.length,
      moodBefore: moodBefore,
    );
    _sessions.insert(0, session);
    await _saveSessions();
    notifyListeners();
  }

  Future<void> updateProgress(String strategyId, int completedSteps, {String? moodAfter}) async {
    final index = _sessions.indexWhere((s) => s.strategyId == strategyId && !s.isCompleted);
    if (index >= 0) {
      _sessions[index] = CopingSession(
        strategyId: _sessions[index].strategyId,
        timestamp: _sessions[index].timestamp,
        completedSteps: completedSteps,
        totalSteps: _sessions[index].totalSteps,
        moodBefore: _sessions[index].moodBefore,
        moodAfter: moodAfter,
      );
      await _saveSessions();
      notifyListeners();
    }
  }

  void setCurrentMood(String? mood) {
    _currentMood = mood;
    notifyListeners();
  }

  Map<String, int> getStrategyUsageStats() {
    final stats = <String, int>{};
    for (final session in _sessions) {
      stats[session.strategyId] = (stats[session.strategyId] ?? 0) + 1;
    }
    return stats;
  }

  List<CopingStrategy> getMostUsedStrategies() {
    final usage = getStrategyUsageStats();
    final sorted = _strategies.toList()
      ..sort((a, b) => (usage[b.id] ?? 0).compareTo(usage[a.id] ?? 0));
    return sorted.take(5).toList();
  }
}
