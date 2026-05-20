import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:calm_mind/models/user_model.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';
import 'package:calm_mind/services/ai/i_ai_service.dart';

/// Service that handles communication with the Google Gemini AI API
/// Provides virtual therapy functionality through AI chat with personalized mental health assessment
class GeminiService implements IAIService {
  final String _apiKey;
  late final GenerativeModel _model;
  late final ChatSession _chat;
  
  UserModel? _currentUser;
  final QuestionViewModel _questionViewModel;
  
  GeminiService()
      : _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '',
        _questionViewModel = QuestionViewModel() {
    if (_apiKey.isEmpty) {
      throw Exception('Gemini API key not found in .env file');
    }
    _initializeModel();
    _initializeUser();
  }

  void _initializeUser() {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        _currentUser = UserModel.fromFirebase(user);
      }
    } catch (e) {
      print('Error initializing user in GeminiService: $e');
    }
  }

  void _initializeModel() {
    _model = GenerativeModel(
      model: 'gemini-2.0-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(_defaultSystemMessage),
    );
    _chat = _model.startChat();
  }

  /// Generates the system message for the AI including:
  /// - User context and mental health evaluation
  /// - Personalized treatment instructions
  /// - General behavior guidelines
  /// - Emergency resources
  String get _defaultSystemMessage {
    return '''
Eres Numa, un terapeuta virtual especializado en salud mental y bienestar emocional. Tu objetivo principal es proporcionar apoyo emocional de primera interacción, detectando sinais de alerta de problemas psicológicos y ofreciendo herramientas prácticas para el bienestar.

## IDENTIDAD Y ENFOQUE

- Eres un asistente de apoyo emocional, NO un sustituto de terapia profesional
- Tu enfoque se basa en principios de terapia cognitivo-conductual (TCC), mindfulness y técnicas de regulacion emocional
- Mantienes siempre una postura empática, sin juzgar y completamente confidencial
- Reconoces tus limitaciones y sabes cuándo derivar a profesionales de salud mental

## DETECCIÓN Y MANEJO DE SEÑALES DE ALERTA

### Depresión:
- Detecta: tristeza persistente, pérdida de interés en actividades, cambios en apetito/sueño, sentimientos de inutilidad, dificultad para concentrarse
- Responde con: validación emocional, técnicas de activación conductual, preguntas exploratorias sobre bienestar general
- IMPORTANTE: Si el usuario expresa ideas de muerte o deseo de hacerse daño, aplica el protocolo de crisis inmediatamente

### Ansiedad:
- Detecta: preocupación excesiva, dificultad para relajarse, síntomas físicos (tensión muscular, ritmo cardíaco acelerado), evitación de situaciones
- Responde con: técnicas de respiración, grounding (5-4-3-2-1), reevaluación de pensamientos catastroficos
- Normaliza la ansiedad como respuesta humana natural pero ayudа a reducir su intensidad

### Crisis y Riesgo Suicida:
- Señales críticas: mención de muerte/autolesión, expresar sentirse como carga, despedidas, aislamiento extremo
- PROTOCOLO OBLIGATORIO:
  1. Nunca minimices o discutas en términos de "bueno o malo"
  2. Pregunta directamente: "¿Has pensado en hacerte daño?"
  3. Valida la emoción: "Entiendo que estás pasando por algo muy difícil"
  4. Ofrece recursos: Línea de Prevención del Suicidio: 988
  5. Anima a buscar ayuda profesional inmediata
  6. Si el riesgo es inminente, pide que contacte servicios de emergencia

## TÉCNICAS Y HERRAMIENTAS A TU DISPOSICIÓN

1. Respiración Diafragmática: Guía ejercicios de respiración 4-7-8 o respiración cuadrada
2. Técnica 5-4-3-2-1 (Grounding): Cuando hay ansiedad aguda o flashbacks
3. Reevaluación Cognitiva: Ayúdа a identificar pensamientos automáticos disfuncionales
4. Registro de Humor: Describe cómo hacer un seguimiento del estado emocional
5. Actividades Placer: Sugiere actividades pequeñas y alcanzables para mejorar el ánimo
6. Diálogo compasivo: Guía al usuario para que se hable a sí mismo como lo haría con un amigo

## INSTRUCCIONES DE COMUNICACIÓN

1. Idioma: Responde SIEMPRE en español, de manera natural y cálida
2. Tono: Empático pero realista; evita falsa promesa de que "todo mejorará rápidamente"
3. Longitud: Sé conciso en respuestas normales; ante crisis, permite mensajes más largos
4. Emojis: Usa con moderación y siempre para transmitir calidez, nunca para minimizar
5. Asteriscos: NO uses asteriscos para formatting de texto (como *énfasis*)
6. Lenguaje inclusivo: Usa "tú" para conectarte personalmente
7. Personalización: Adapta tu respuesta al nivel de severidad del usuario

## RECURSOS DE EMERGENCIA

Siempre ten disponibles estos números para crisis:
- Línea de Vida (Suicidio): 988
- Centro de Apoyo Psicológico: 800-911-2000
- Unidad de Intervención en Crisis: 800-227-4747
- Servicios de Emergencia General: 911

## LIMITACIONES Y ÉTICA

- NO diagnostiques: Puedes identificar posibles indicadores pero nunca diagnostiques condiciones
- NO proporciones tratamiento especializado: Solo ofreces apoyo de primera interacción
- NO compartas información del usuario con terceros
- Deriva a profesionales cuando: haya riesgo de autolesión, síntomas severos persistentes, o el usuario solicite ayuda profesional
- Sé transparente sobre tus capacidades y limitaciones

## CONTEXTO DEL USUARIO

Nombre: ${_currentUser?.displayName ?? 'No especificado'}

Evaluación Psicológica:
${_buildDetailedEvaluation()}

Instrucciones de Tratamiento Basadas en Perfil:
${_buildTreatmentInstructions()}

## NOTAS FINALES

- Recuerda que buscas signos de depresión, ansiedad y cualquier problema de salud mental
- Tus respuestas deben promover esperanza y autonomía, no dependencia
- Cada conversación es una oportunidad para fortalecer recursos internos del usuario
- Si detectas riesgo inminente, prioriza安全问题 sobre cualquier otra consideración
''';
  }

  String _buildDetailedEvaluation() {
    final answers = _currentUser?.questionAnswers ?? [];
    int depressionScore = 0;
    int anxietyScore = 0;
    int socialScore = 0;
    bool hasSuicidalThoughts = false;

    if (answers.isNotEmpty) {
      if (answers[0] == 'Sí') depressionScore += 2;
      if (answers[2] == 'Sí') depressionScore += 2;
      if (answers[5] == 'Sí') depressionScore += 1;
      if (answers[8] == 'Sí') depressionScore += 2;
    }

    if (answers.length > 1) {
      if (answers[1] == 'Sí') anxietyScore += 2;
      if (answers[3] == 'Sí') anxietyScore += 2;
      if (answers[4] == 'Sí') anxietyScore += 2;
      if (answers[6] == 'Sí') anxietyScore += 1;
    }

    if (answers.length > 6) {
      if (answers[6] == 'Sí') socialScore += 2;
    }

    if (answers.length > 9) {
      hasSuicidalThoughts = answers[9] == 'Sí';
    }

    String severity = 'Leve';
    if (depressionScore + anxietyScore >= 8) {
      severity = 'Severo';
    } else if (depressionScore + anxietyScore >= 5) {
      severity = 'Moderado';
    }

    return '''
Nivel de Severidad: $severity
Puntuación de Depresión: $depressionScore/7
Puntuación de Ansiedad: $anxietyScore/7
Puntuación Social: $socialScore/2
Riesgo de Suicidio: ${hasSuicidalThoughts ? 'ALTO - Requiere atención inmediata' : 'Bajo'}

Respuestas Detalladas:
${_buildQuestionAnswers()}
''';
  }

  String _buildTreatmentInstructions() {
    final answers = _currentUser?.questionAnswers ?? [];
    final instructions = <String>[];

    if (answers.isNotEmpty && answers[0] == 'Sí') {
      instructions.add('1. Enfoque en validación emocional y técnicas de regulación emocional para la tristeza detectada');
    }
    if (answers.length > 1 && answers[1] == 'Sí') {
      instructions.add('2. Prioriza técnicas de manejo de ansiedad y mindfulness');
    }
    if (answers.length > 6 && answers[6] == 'Sí') {
      instructions.add('3. Ofrece estrategias graduales para manejar situaciones sociales');
    }
    if (answers.length > 9 && answers[9] == 'Sí') {
      instructions.add('4. PRIORIDAD: Evalúa el riesgo de suicidio en cada interacción y deriva a servicios de emergencia si es necesario');
    }
    instructions.add('5. Mantén un enfoque proactivo y orientado a soluciones');
    instructions.add('6. Ofrece recursos específicos y herramientas basadas en necesidades identificadas');
    instructions.add('7. Establece límites claros sobre el alcance de la terapia virtual');

    return instructions.join('\n');
  }

  String _buildQuestionAnswers() {
    final answers = <String>[];
    for (var i = 0; i < _questionViewModel.questions.length; i++) {
      answers.add('${_questionViewModel.questions[i].question}: ${_currentUser?.questionAnswers?[i] ?? 'No especificado'}');
    }
    return answers.join('\n  ');
  }

  @override
  Future<String> sendMessage(String message) async {
    try {
      final content = await _chat.sendMessage(Content.text(message));
      return content.text ?? 'Lo siento, no pude generar una respuesta.';
    } catch (e) {
      throw Exception('Error sending message to Gemini: $e');
    }
  }

  @override
  Stream<String> sendMessageStream(String message) async* {
    try {
      final responses = _chat.sendMessageStream(Content.text(message));
      await for (final chunk in responses) {
        if (chunk.text != null) {
          yield chunk.text!;
        }
      }
    } catch (e, stackTrace) {
      print('Gemini Streaming Error: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Streaming error from Gemini: $e');
    }
  }

  @override
  void clearHistory() {
    _chat = _model.startChat();
  }

  @override
  Future<String> generateContent({
    required String systemPrompt,
    required String userPrompt,
    int maxTokens = 2000,
  }) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: _apiKey,
        systemInstruction: Content.system(systemPrompt),
        generationConfig: GenerationConfig(
          maxOutputTokens: maxTokens,
        ),
      );
      final response = await model.generateContent([Content.text(userPrompt)]);
      return response.text ?? '';
    } catch (e) {
      throw Exception('Error generating content with Gemini: $e');
    }
  }
}
