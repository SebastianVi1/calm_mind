import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import '../models/forum_post.dart';

class ForumViewModel extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  String _checkInMood = '';
  final TextEditingController postController = TextEditingController();

  bool get isLoading => _isLoading;
  String? get error => _error;
  String get checkInMood => _checkInMood;

  final List<ForumPost> _posts = [];
  final List<GroupChallenge> _challenges = [];

  List<ForumPost> get posts => _posts;
  List<GroupChallenge> get challenges => _challenges;

  ForumViewModel() {
    _loadSamplePosts();
    _loadChallenges();
    WidgetsBinding.instance.addPostFrameCallback((_) => notifyListeners());
  }

  void _loadSamplePosts() {
    final now = DateTime.now();
    _posts.addAll([
      ForumPost(
        id: '1',
        content:
            'Empecé el día con 10 minutos de meditación guiada. Me siento mucho más centrado y tranquilo. Se las recomiendo a todos.',
        moodTag: 'Feliz',
        authorName: 'Luna',
        timestamp: now.subtract(const Duration(minutes: 23)),
        likeCount: 7,
      ),
      ForumPost(
        id: '2',
        content:
            'Hoy no ha sido un buen día. La ansiedad me ganó un poco, pero pude aplicar la técnica 4-7-8 que aprendí aquí. Me ayudó bastante.',
        moodTag: 'Triste',
        timestamp: now.subtract(const Duration(hours: 1)),
        likeCount: 4,
      ),
      ForumPost(
        id: '3',
        content:
            'El kit de estrategias de afrontamiento ha cambiado mi vida. Llevo 3 semanas usando las técnicas y mi ansiedad se ha reducido notablemente.',
        moodTag: 'Neutral',
        authorName: 'Marco',
        timestamp: now.subtract(const Duration(hours: 3)),
        likeCount: 11,
      ),
      ForumPost(
        id: '4',
        content:
            'Alguien más siente que la música relajante de la sección de meditación es increíble? Perfecta para estudiar o trabajar.',
        moodTag: 'Feliz',
        authorName: 'Sofía',
        timestamp: now.subtract(const Duration(hours: 5, minutes: 30)),
        likeCount: 15,
      ),
      ForumPost(
        id: '5',
        content:
            'Primera vez usando la app. Hice el test inicial y me sorprendió lo acertado que fue. Gracias por crear esta comunidad.',
        moodTag: 'Feliz',
        timestamp: now.subtract(const Duration(hours: 8)),
        likeCount: 3,
      ),
    ]);
  }

  void _loadChallenges() {
    _challenges.addAll([
      const GroupChallenge(
        id: 'c1',
        title: 'Meditación Diaria',
        description: 'Medita 5 minutos al día durante 7 días',
        emoji: '🧘',
        participantCount: 34,
      ),
      const GroupChallenge(
        id: 'c2',
        title: 'Diario de Gratitud',
        description: 'Escribe 3 cosas que agradeces cada día',
        emoji: '📓',
        participantCount: 27,
      ),
      const GroupChallenge(
        id: 'c3',
        title: 'Desconexión Digital',
        description: '1 hora sin pantallas antes de dormir',
        emoji: '📵',
        participantCount: 19,
      ),
      const GroupChallenge(
        id: 'c4',
        title: 'Movimiento Consciente',
        description: '15 minutos de ejercicio suave diario',
        emoji: '🚶',
        participantCount: 22,
      ),
    ]);
  }

  void setCheckInMood(String mood) {
    _checkInMood = mood;
    notifyListeners();
  }

  void addPost() {
    final content = postController.text.trim();
    if (content.isEmpty) return;

    final post = ForumPost(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      moodTag: _checkInMood.isNotEmpty ? _checkInMood : null,
      timestamp: DateTime.now(),
    );

    _posts.insert(0, post);
    postController.clear();
    _checkInMood = '';
    notifyListeners();
  }

  void toggleLike(int index) {
    if (index < 0 || index >= _posts.length) return;
    final old = _posts[index];
    _posts[index] = ForumPost(
      id: old.id,
      content: old.content,
      moodTag: old.moodTag,
      authorName: old.authorName,
      timestamp: old.timestamp,
      likeCount: old.likeCount + 1,
    );
    notifyListeners();
  }

  @override
  void dispose() {
    postController.dispose();
    super.dispose();
  }
}
