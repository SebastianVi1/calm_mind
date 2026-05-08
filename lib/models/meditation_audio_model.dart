class MeditationAudioModel {
  final String url;
  final String title;
  final String duration;
  final String category;

  MeditationAudioModel({
    required this.url, 
    required this.title, 
    required this.duration, 
    required this.category,
  });

  /// Creates a model from Firestore data
  factory MeditationAudioModel.fromJson(Map<String, dynamic> json) {
    return MeditationAudioModel(
      url: json['url'] ?? '',
      title: json['title'] ?? 'Unknown',
      duration: json['duration'] ?? '0:00',
      category: json['category'] ?? 'General',
    );
  }

  /// Converts the model to JSON for Firestore
  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'duration': duration,
      'category': category,
    };
  }
}
