import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:uuid/uuid.dart';
import '../models/patient_report_model.dart';
import '../models/user_model.dart';
import '../models/question_model.dart';

/// Service that handles patient report generation using AI
/// Uses DeepSeek API to analyze questionnaire responses and generate detailed reports
class PatientReportService {
  static const String _baseUrl = 'https://api.deepseek.com';
  final String _apiKey;
  final _uuid = const Uuid();

  PatientReportService() : _apiKey = dotenv.env['DEEPSEEK_API_KEY'] ?? '' {
    if (_apiKey.isEmpty) {
      throw Exception('DeepSeek API key not found in .env file');
    }
  }

  /// Generates a complete patient report based on questionnaire responses
  /// [user] - User model
  /// [questionnaireAnswers] - Questionnaire responses
  /// [questions] - List of questionnaire questions
  /// Returns PatientReportModel with complete analysis
  Future<PatientReportModel> generatePatientReport({
    required UserModel user,
    required List<String> questionnaireAnswers,
    required List<QuestionModel> questions,
  }) async {
    try {
      final reportId = _uuid.v4();
      final now = DateTime.now();

      // Construir el prompt para la IA
      final prompt = _buildReportPrompt(user, questionnaireAnswers, questions);

      // Llamar a la API de DeepSeek
      final aiResponse = await _callDeepSeekAPI(prompt);

      // Parsear la respuesta de la IA
      final parsedReport = _parseAIResponse(aiResponse);

      // Crear el modelo del reporte
      return PatientReportModel(
        id: reportId,
        userId: user.uid,
        createdAt: now,
        lastUpdated: now,
        executiveSummary: parsedReport['executiveSummary'] ?? '',
        symptomAnalysis: parsedReport['symptomAnalysis'] ?? '',
        riskLevel: _parseRiskLevel(parsedReport['riskLevel'] ?? 'medium'),
        recommendations: List<String>.from(parsedReport['recommendations'] ?? []),
        suggestedResources: List<String>.from(parsedReport['suggestedResources'] ?? []),
        nextSteps: parsedReport['nextSteps'] ?? '',
        additionalNotes: parsedReport['additionalNotes'] ?? '',
        wellnessScore: parsedReport['wellnessScore'] ?? 50,
        questionnaireAnswers: questionnaireAnswers,
        questionnaireDate: now,
      );
    } catch (e) {
      throw Exception('Error generando reporte del paciente: $e');
    }
  }

  /// Construye el prompt detallado para la IA
  String _buildReportPrompt(UserModel user, List<String> answers, List<QuestionModel> questions) {
    final userInfo = '''
INFORMACIÓN DEL PACIENTE:
- Nombre: ${user.displayName ?? 'No especificado'}
- Email: ${user.email ?? 'No especificado'}
- ID: ${user.uid}
''';

    String questionnaireData = '''
RESPUESTAS DEL CUESTIONARIO DE SALUD MENTAL:
''';

    for (int i = 0; i < questions.length && i < answers.length; i++) {
      questionnaireData += '''
${i + 1}. ${questions[i].question}
   Respuesta: ${answers[i]}
   Descripción: ${questions[i].description}
''';
    }

    return '''
Eres un psicólogo clínico experto que debe generar un reporte profesional de evaluación de salud mental basado en las respuestas de un cuestionario.

$userInfo

$questionnaireData

INSTRUCCIONES PARA EL REPORTE:

Genera un reporte completo en formato JSON con la siguiente estructura:

{
  "executiveSummary": "Resumen ejecutivo de 2-3 párrafos sobre el estado mental general del paciente",
  "symptomAnalysis": "Análisis detallado de los síntomas identificados, patrones de comportamiento y áreas de preocupación",
  "riskLevel": "low/medium/high - Nivel de riesgo basado en las respuestas",
  "recommendations": ["Recomendación 1", "Recomendación 2", "Recomendación 3"],
  "suggestedResources": ["Recurso 1", "Recurso 2", "Recurso 3"],
  "nextSteps": "Pasos específicos recomendados para el paciente",
  "additionalNotes": "Observaciones adicionales importantes",
  "wellnessScore": 75
}

CRITERIOS DE EVALUACIÓN:
- Respuestas "Sí" a preguntas sobre tristeza, ansiedad, pérdida de interés = Mayor riesgo
- Respuestas "Sí" a pensamientos suicidas = Riesgo alto (prioridad máxima)
- Respuestas "No" a la mayoría = Riesgo bajo
- Patrones mixtos = Riesgo medio

RECOMENDACIONES ESPECÍFICAS:
- Para riesgo alto: Derivación inmediata a profesional de salud mental
- Para riesgo medio: Terapia, técnicas de relajación, seguimiento regular
- Para riesgo bajo: Mantenimiento de bienestar, técnicas preventivas

FORMATO DE RESPUESTA:
Responde ÚNICAMENTE con el JSON válido, sin texto adicional.
''';
  }

  /// Llama a la API de DeepSeek para generar el reporte
  Future<String> _callDeepSeekAPI(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': 'deepseek-chat',
          'messages': [
            {
              'role': 'system',
              'content': 'Eres un psicólogo clínico experto especializado en evaluación de salud mental. Genera reportes profesionales basados en cuestionarios de salud mental.',
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.3, // Temperatura baja para respuestas más consistentes
          'max_tokens': 2000,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'];
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error llamando a DeepSeek API: $e');
    }
  }

  /// Parsea la respuesta de la IA y extrae los datos del reporte
  Map<String, dynamic> _parseAIResponse(String aiResponse) {
    try {
      // Limpiar la respuesta para extraer solo el JSON
      String cleanedResponse = aiResponse.trim();
      
      // Buscar el JSON en la respuesta
      final jsonStart = cleanedResponse.indexOf('{');
      final jsonEnd = cleanedResponse.lastIndexOf('}') + 1;
      
      if (jsonStart != -1 && jsonEnd > jsonStart) {
        cleanedResponse = cleanedResponse.substring(jsonStart, jsonEnd);
      }

      final Map<String, dynamic> parsed = jsonDecode(cleanedResponse);
      
      // Validar que todos los campos requeridos estén presentes
      return {
        'executiveSummary': parsed['executiveSummary'] ?? 'No disponible',
        'symptomAnalysis': parsed['symptomAnalysis'] ?? 'No disponible',
        'riskLevel': parsed['riskLevel'] ?? 'medium',
        'recommendations': parsed['recommendations'] ?? ['Consulta con un profesional de salud mental'],
        'suggestedResources': parsed['suggestedResources'] ?? ['Recursos de salud mental'],
        'nextSteps': parsed['nextSteps'] ?? 'Seguimiento recomendado',
        'additionalNotes': parsed['additionalNotes'] ?? 'Sin observaciones adicionales',
        'wellnessScore': parsed['wellnessScore'] ?? 50,
      };
    } catch (e) {
      // Si falla el parsing, crear un reporte básico
      return _createFallbackReport();
    }
  }

  /// Crea un reporte básico en caso de error en el parsing
  Map<String, dynamic> _createFallbackReport() {
    return {
      'executiveSummary': 'Se ha completado la evaluación inicial de salud mental. Se recomienda consultar con un profesional para un análisis más detallado.',
      'symptomAnalysis': 'Se requiere evaluación adicional por parte de un profesional de salud mental para un análisis completo de los síntomas.',
      'riskLevel': 'medium',
      'recommendations': [
        'Consulta con un psicólogo o psiquiatra',
        'Mantén un registro de tu estado de ánimo',
        'Practica técnicas de relajación'
      ],
      'suggestedResources': [
        'Terapia psicológica',
        'Grupos de apoyo',
        'Recursos de autoayuda'
      ],
      'nextSteps': 'Programa una cita con un profesional de salud mental para evaluación completa.',
      'additionalNotes': 'Este reporte fue generado automáticamente. Se recomienda evaluación profesional.',
      'wellnessScore': 50,
    };
  }

  /// Convierte el string de nivel de riesgo a enum
  RiskLevel _parseRiskLevel(String riskLevelString) {
    switch (riskLevelString.toLowerCase()) {
      case 'low':
      case 'bajo':
        return RiskLevel.low;
      case 'high':
      case 'alto':
        return RiskLevel.high;
      case 'medium':
      case 'medio':
      default:
        return RiskLevel.medium;
    }
  }

  /// Genera un resumen rápido del reporte para mostrar en la UI
  String generateQuickSummary(PatientReportModel report) {
    return '''
Resumen del Reporte:
• Nivel de Riesgo: ${report.riskLevel.displayName}
• Puntuación de Bienestar: ${report.wellnessScore}/100
• Recomendaciones: ${report.recommendations.length} sugerencias
• Fecha: ${_formatDate(report.createdAt)}
''';
  }

  /// Formatea la fecha para mostrar
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
