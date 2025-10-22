import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for AI-generated assessment reports
class AIAssessmentReport {
  final String id;
  final String userId;
  final String data; // JSON data of the assessment
  final DateTime createdAt;

  AIAssessmentReport({
    required this.id,
    required this.userId,
    required this.data,
    required this.createdAt,
  });

  /// Creates an instance from Firestore document data
  factory AIAssessmentReport.fromJson(Map<String, dynamic> json) {
    return AIAssessmentReport(
      id: json['id'] as String,
      userId: json['userId'] as String,
      data: json['data'] as String,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Converts the instance to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

class AIAssessmentService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'ai_assessments';

  /// Retrieve reports for a specific user
  Future<List<AIAssessmentReport>> getReportsByUserId(String userId) async {
    try {
      print('DEBUG: Fetching reports for user: $userId');

      final snapshot =
          await _db
              .collection(_collection)
              .where('userId', isEqualTo: userId)
              .orderBy('createdAt', descending: true)
              .get();

      print('DEBUG: Found ${snapshot.docs.length} reports');

      final reports =
          snapshot.docs
              .map((doc) {
                try {
                  return AIAssessmentReport.fromJson(doc.data());
                } catch (e) {
                  print('ERROR parsing report: $e');
                  return null;
                }
              })
              .whereType<AIAssessmentReport>()
              .toList();

      print('DEBUG: Successfully parsed ${reports.length} reports');
      return reports;
    } catch (e) {
      print('ERROR fetching reports: $e');
      return [];
    }
  }

  // ...existing methods...
}
