import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo que representa un reporte de paciente generado por IA
/// Contiene análisis detallado basado en las respuestas del cuestionario
class PatientReportModel {
  /// ID único del reporte
  final String id;
  
  /// ID del usuario al que pertenece el reporte
  final String userId;
  
  /// Fecha de creación del reporte
  final DateTime createdAt;
  
  /// Fecha de la última actualización
  final DateTime lastUpdated;
  
  /// Resumen ejecutivo del estado mental del paciente
  final String executiveSummary;
  
  /// Análisis detallado de síntomas identificados
  final String symptomAnalysis;
  
  /// Nivel de riesgo evaluado (Bajo, Medio, Alto)
  final RiskLevel riskLevel;
  
  /// Recomendaciones específicas para el paciente
  final List<String> recommendations;
  
  /// Recursos sugeridos (terapia, medicación, etc.)
  final List<String> suggestedResources;
  
  /// Próximos pasos recomendados
  final String nextSteps;
  
  /// Observaciones adicionales del análisis
  final String additionalNotes;
  
  /// Puntuación de bienestar mental (0-100)
  final int wellnessScore;
  
  /// Respuestas del cuestionario que generaron este reporte
  final List<String> questionnaireAnswers;
  
  /// Fecha de las respuestas del cuestionario
  final DateTime questionnaireDate;

  const PatientReportModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.lastUpdated,
    required this.executiveSummary,
    required this.symptomAnalysis,
    required this.riskLevel,
    required this.recommendations,
    required this.suggestedResources,
    required this.nextSteps,
    required this.additionalNotes,
    required this.wellnessScore,
    required this.questionnaireAnswers,
    required this.questionnaireDate,
  });

  /// Crea una copia del modelo con valores actualizados
  PatientReportModel copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    DateTime? lastUpdated,
    String? executiveSummary,
    String? symptomAnalysis,
    RiskLevel? riskLevel,
    List<String>? recommendations,
    List<String>? suggestedResources,
    String? nextSteps,
    String? additionalNotes,
    int? wellnessScore,
    List<String>? questionnaireAnswers,
    DateTime? questionnaireDate,
  }) {
    return PatientReportModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      executiveSummary: executiveSummary ?? this.executiveSummary,
      symptomAnalysis: symptomAnalysis ?? this.symptomAnalysis,
      riskLevel: riskLevel ?? this.riskLevel,
      recommendations: recommendations ?? this.recommendations,
      suggestedResources: suggestedResources ?? this.suggestedResources,
      nextSteps: nextSteps ?? this.nextSteps,
      additionalNotes: additionalNotes ?? this.additionalNotes,
      wellnessScore: wellnessScore ?? this.wellnessScore,
      questionnaireAnswers: questionnaireAnswers ?? this.questionnaireAnswers,
      questionnaireDate: questionnaireDate ?? this.questionnaireDate,
    );
  }

  /// Convierte el modelo a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'executiveSummary': executiveSummary,
      'symptomAnalysis': symptomAnalysis,
      'riskLevel': riskLevel.name,
      'recommendations': recommendations,
      'suggestedResources': suggestedResources,
      'nextSteps': nextSteps,
      'additionalNotes': additionalNotes,
      'wellnessScore': wellnessScore,
      'questionnaireAnswers': questionnaireAnswers,
      'questionnaireDate': Timestamp.fromDate(questionnaireDate),
    };
  }

  /// Crea el modelo desde un Map de Firebase
  factory PatientReportModel.fromMap(Map<String, dynamic> map) {
    return PatientReportModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated: (map['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      executiveSummary: map['executiveSummary'] ?? '',
      symptomAnalysis: map['symptomAnalysis'] ?? '',
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == map['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      recommendations: List<String>.from(map['recommendations'] ?? []),
      suggestedResources: List<String>.from(map['suggestedResources'] ?? []),
      nextSteps: map['nextSteps'] ?? '',
      additionalNotes: map['additionalNotes'] ?? '',
      wellnessScore: map['wellnessScore'] ?? 50,
      questionnaireAnswers: List<String>.from(map['questionnaireAnswers'] ?? []),
      questionnaireDate: (map['questionnaireDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'executiveSummary': executiveSummary,
      'symptomAnalysis': symptomAnalysis,
      'riskLevel': riskLevel.name,
      'recommendations': recommendations,
      'suggestedResources': suggestedResources,
      'nextSteps': nextSteps,
      'additionalNotes': additionalNotes,
      'wellnessScore': wellnessScore,
      'questionnaireAnswers': questionnaireAnswers,
      'questionnaireDate': questionnaireDate.toIso8601String(),
    };
  }

  /// Crea el modelo desde JSON
  factory PatientReportModel.fromJson(Map<String, dynamic> json) {
    return PatientReportModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      lastUpdated: DateTime.parse(json['lastUpdated'] ?? DateTime.now().toIso8601String()),
      executiveSummary: json['executiveSummary'] ?? '',
      symptomAnalysis: json['symptomAnalysis'] ?? '',
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.medium,
      ),
      recommendations: List<String>.from(json['recommendations'] ?? []),
      suggestedResources: List<String>.from(json['suggestedResources'] ?? []),
      nextSteps: json['nextSteps'] ?? '',
      additionalNotes: json['additionalNotes'] ?? '',
      wellnessScore: json['wellnessScore'] ?? 50,
      questionnaireAnswers: List<String>.from(json['questionnaireAnswers'] ?? []),
      questionnaireDate: DateTime.parse(json['questionnaireDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  @override
  String toString() {
    return 'PatientReportModel(id: $id, userId: $userId, riskLevel: $riskLevel, wellnessScore: $wellnessScore)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PatientReportModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum para representar los niveles de riesgo
enum RiskLevel {
  low('Bajo'),
  medium('Medio'),
  high('Alto');

  const RiskLevel(this.displayName);
  final String displayName;
}
