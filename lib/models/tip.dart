class Tip {
  final String id;
  final String title;
  final String content;
  final String category;

  Tip({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  Tip.fromJson(Map<String, dynamic> json) : 
        this(
          id: json['id'] as String,
          title: json['title'] as String,
          content: json['content'] as String,
          category: json['category'] as String,
        );


  factory Tip.fromMap(Map<String, dynamic> map) {
    return Tip(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
    };
  }
} 