class MeditationAudioModel {
  final String url;
  final String title;
  final String duration;
  final String category;
  final String storyTopic;
  final String? audioPrompt;
  final String assetPath;

  const MeditationAudioModel({
    this.url = '',
    required this.title,
    required this.duration,
    required this.category,
    this.storyTopic = '',
    this.audioPrompt,
    this.assetPath = '',
  });

  factory MeditationAudioModel.fromJson(Map<String, dynamic> json) {
    return MeditationAudioModel(
      url: json['url'] ?? '',
      title: json['title'] ?? 'Unknown',
      duration: json['duration'] ?? '0:00',
      category: json['category'] ?? 'General',
      storyTopic: json['storyTopic'] ?? '',
      audioPrompt: json['audioPrompt'],
      assetPath: json['assetPath'] ?? '',
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
      'assetPath': assetPath,
    };
  }

  bool get isLocalAsset => assetPath.isNotEmpty;
  bool get isAiGenerated =>
      storyTopic.isNotEmpty || (audioPrompt != null && audioPrompt!.isNotEmpty);

  /// Returns all bundled local meditations. The list is hardcoded to
  /// avoid depending on AssetManifest.json (which can be stale).
  static List<MeditationAudioModel> localMeditations() {
    return const [
      MeditationAudioModel(
        title: 'Meditación guiada',
        duration: '17:00',
        category: 'Guiada',
        assetPath: 'assets/meditation_audios/meditation_1.mp3',
      ),
      MeditationAudioModel(
        title: 'Elimina tu ansiedad',
        duration: '16:00',
        category: 'Ansiedad',
        assetPath: 'assets/meditation_audios/Elimina_tu_ansiedad.mp3',
      ),
      MeditationAudioModel(
        title: 'Reduce el estrés',
        duration: '11:00',
        category: 'Estrés',
        assetPath: 'assets/meditation_audios/Reduce_el_estres.mp3',
      ),
      MeditationAudioModel(
        title: 'Confiar en ti',
        duration: '10:00',
        category: 'Autoestima',
        assetPath: 'assets/meditation_audios/Meditacion_para_confiar_en_ti.mp3',
      ),
      MeditationAudioModel(
        title: 'Mindfulness',
        duration: '7:00',
        category: 'Mindfulness',
        assetPath: 'assets/meditation_audios/7_Minutos_mindfullness.mp3',
      ),
    ];
  }
}
