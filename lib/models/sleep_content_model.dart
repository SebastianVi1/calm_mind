import 'dart:ui';

enum SleepContentType { ambient, story }

class SleepContentModel {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String icon;
  final SleepContentType type;
  final int? durationMinutes;
  final String? lottieAsset;
  final String gradientStart;
  final String gradientEnd;
  final String audioPrompt;
  final String storyTopic;
  final bool isLoopable;

  const SleepContentModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.icon,
    required this.type,
    this.durationMinutes,
    this.lottieAsset,
    required this.gradientStart,
    required this.gradientEnd,
    this.audioPrompt = '',
    this.storyTopic = '',
    this.isLoopable = false,
  });

  static List<SleepContentModel> ambientSounds() => const [
    SleepContentModel(
      id: 'rain',
      title: 'Lluvia Suave',
      subtitle: 'Sonido de lluvia relajante',
      category: 'Naturaleza',
      icon: '🌧️',
      type: SleepContentType.ambient,
      gradientStart: '#1A237E',
      gradientEnd: '#4A148C',
      audioPrompt: 'Soft gentle rain falling on leaves, calming ambient',
      isLoopable: true,
    ),
    SleepContentModel(
      id: 'forest',
      title: 'Bosque Nocturno',
      subtitle: 'Grillos y brisa entre árboles',
      category: 'Naturaleza',
      icon: '🌲',
      type: SleepContentType.ambient,
      gradientStart: '#1B5E20',
      gradientEnd: '#004D40',
      audioPrompt: 'Night forest with crickets and gentle breeze',
      isLoopable: true,
    ),
    SleepContentModel(
      id: 'waves',
      title: 'Olas del Mar',
      subtitle: 'Olas suaves en la orilla',
      category: 'Naturaleza',
      icon: '🌊',
      type: SleepContentType.ambient,
      gradientStart: '#01579B',
      gradientEnd: '#006064',
      audioPrompt: 'Ocean waves gently crashing on shore at night',
      isLoopable: true,
    ),
    SleepContentModel(
      id: 'fireplace',
      title: 'Chimenea',
      subtitle: 'Fuego crepitante acogedor',
      category: 'Hogar',
      icon: '🔥',
      type: SleepContentType.ambient,
      gradientStart: '#BF360C',
      gradientEnd: '#4E342E',
      audioPrompt: 'Cozy fireplace crackling fire, warm ambient',
      isLoopable: true,
    ),
    SleepContentModel(
      id: 'whitenoise',
      title: 'Ruido Blanco',
      subtitle: 'Sonido constante y envolvente',
      category: 'Sonidos',
      icon: '💨',
      type: SleepContentType.ambient,
      gradientStart: '#37474F',
      gradientEnd: '#263238',
      audioPrompt: 'White noise static smooth constant',
      isLoopable: true,
    ),
    SleepContentModel(
      id: 'wind',
      title: 'Viento Suave',
      subtitle: 'Brisa entre hojas',
      category: 'Naturaleza',
      icon: '🍃',
      type: SleepContentType.ambient,
      gradientStart: '#33691E',
      gradientEnd: '#558B2F',
      audioPrompt: 'Gentle wind blowing through leaves, soft breeze',
      isLoopable: true,
    ),
  ];

  static List<SleepContentModel> sleepStories() => const [
    SleepContentModel(
      id: 'story1',
      title: 'El Bosque de los Sueños',
      subtitle: 'Un viaje por un bosque mágico al atardecer',
      category: 'Naturaleza',
      icon: '📖',
      type: SleepContentType.story,
      durationMinutes: 15,
      gradientStart: '#2E7D32',
      gradientEnd: '#1B5E20',
      storyTopic: 'Un bosque mágico al atardecer donde los animales duermen pacíficamente',
      isLoopable: false,
    ),
    SleepContentModel(
      id: 'story2',
      title: 'Bajo las Estrellas',
      subtitle: 'Una noche observando el cielo estrellado',
      category: 'Aventura',
      icon: '📖',
      type: SleepContentType.story,
      durationMinutes: 20,
      gradientStart: '#1565C0',
      gradientEnd: '#1A237E',
      storyTopic: 'Una noche observando el cielo estrellado en una montaña tranquila',
      isLoopable: false,
    ),
    SleepContentModel(
      id: 'story3',
      title: 'El Lago Tranquilo',
      subtitle: 'La calma de un lago al amanecer',
      category: 'Naturaleza',
      icon: '📖',
      type: SleepContentType.story,
      durationMinutes: 18,
      gradientStart: '#00695C',
      gradientEnd: '#004D40',
      storyTopic: 'La calma de un lago al amanecer con niebla suave',
      isLoopable: false,
    ),
    SleepContentModel(
      id: 'story4',
      title: 'Viaje en las Nubes',
      subtitle: 'Flotando suavemente entre nubes algodonosas',
      category: 'Relajación',
      icon: '📖',
      type: SleepContentType.story,
      durationMinutes: 12,
      gradientStart: '#7B1FA2',
      gradientEnd: '#4A148C',
      storyTopic: 'Flotando suavemente entre nubes algodonosas en un cielo tranquilo',
      isLoopable: false,
    ),
  ];

  Color get startColor => Color(int.parse(gradientStart.replaceFirst('#', '0xFF')));
  Color get endColor => Color(int.parse(gradientEnd.replaceFirst('#', '0xFF')));
}
