class RelaxingMusicModel {
  String name;
  String author;
  String url;
  String duration;
  String? localPath;
  RelaxingMusicModel({
    required this.name,
    required this.author,
    required this.url,
    required this.duration,
    this.localPath,
  });

  factory RelaxingMusicModel.fromJson(Map<String, dynamic> json) {
    return RelaxingMusicModel(
      name: json['name'] ?? 'Sin nombre',
      author: json['author'] ?? 'Sin autor',
      url: json['url'],
      duration: json['duration'],
      localPath: json['localPath'],
    );
  }
}
