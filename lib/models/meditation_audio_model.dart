class MeditationAudioModel {
  final String url;
  final String title;
  final String duration;
  final String category;
  final String storyTopic;
  final String? audioPrompt;

  MeditationAudioModel({
    this.url = '',
    required this.title,
    required this.duration,
    required this.category,
    this.storyTopic = '',
    this.audioPrompt,
  });

  factory MeditationAudioModel.fromJson(Map<String, dynamic> json) {
    return MeditationAudioModel(
      url: json['url'] ?? '',
      title: json['title'] ?? 'Unknown',
      duration: json['duration'] ?? '0:00',
      category: json['category'] ?? 'General',
      storyTopic: json['storyTopic'] ?? '',
      audioPrompt: json['audioPrompt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'title': title,
      'duration': duration,
      'category': category,
      'storyTopic': storyTopic,
      'audioPrompt': audioPrompt,
    };
  }

  bool get isAiGenerated => storyTopic.isNotEmpty || (audioPrompt != null && audioPrompt!.isNotEmpty);
}
