class QuestionModel {
  final String question;
  final String description;
  final List<String> options;

  QuestionModel({
    required this.question,
    required this.description,
    required this.options,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      question: json['question'] ?? '',
      description: json['description'] ?? '',
      options: List<String>.from(json['options'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question': question,
      'description': description,
      'options': options,
    };
  }
} 