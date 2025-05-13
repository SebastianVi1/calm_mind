class RelaxingMusicModel {
  String name;
  String author;
  String url;
  String duration;
  RelaxingMusicModel({
    required this.name,
    required this.author,
    required this.url,
    required this.duration,
  });

  factory RelaxingMusicModel.fromJson(Map<String, dynamic> json) {
    return RelaxingMusicModel(
      name: json['name'] ?? 'Sin nombre',
      author: json['author'] ?? 'Sin autor',
      url: json['url'],
      duration: json['duration'],
    );
  }


}
