import 'dart:math';

class ForumPost {
  final String id;
  final String content;
  final String? moodTag;
  final String? authorName;
  final DateTime timestamp;
  final int likeCount;

  const ForumPost({
    required this.id,
    required this.content,
    this.moodTag,
    this.authorName,
    required this.timestamp,
    this.likeCount = 0,
  });

  String get displayName => authorName ?? 'Anónimo';
  String get timeAgo => _formatTimeAgo(timestamp);
  String get moodEmoji {
    switch (moodTag) {
      case 'Feliz':
        return '😊';
      case 'Neutral':
        return '😐';
      case 'Enojado':
        return '😠';
      case 'Triste':
        return '😢';
      default:
        return '💭';
    }
  }

  static String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}s';
  }
}

class GroupChallenge {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final int participantCount;
  final int totalDays;

  const GroupChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.participantCount = 0,
    this.totalDays = 7,
  });

  int get randomParticipants => participantCount + Random().nextInt(50);
}
