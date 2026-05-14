class RelaxingMusicModel {
  String name;
  String author;
  String url;
  String duration;
  String? localPath;
  String category; // Added for mood-based filtering (e.g., 'Calming', 'Uplifting', 'Peaceful')

  RelaxingMusicModel({
    required this.name,
    required this.author,
    required this.url,
    required this.duration,
    required this.category,
    this.localPath,
  });

  factory RelaxingMusicModel.fromJson(Map<String, dynamic> json) {
    return RelaxingMusicModel(
      name: json['name'] ?? 'Sin nombre',
      author: json['author'] ?? 'Sin autor',
      url: json['url'] ?? '',
      duration: json['duration'] ?? '0:00',
      category: json['category'] ?? 'General',
      localPath: json['localPath'],
    );
  }
}
