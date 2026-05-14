import 'package:calm_mind/models/achievement_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/achievement_view_model.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Logros',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        centerTitle: true,
      ),
      body: Consumer<AchievementViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PointsBanner(
                totalPoints: viewModel.totalPoints,
                unlockedCount: viewModel.achievements
                    .where((a) => a.isUnlocked)
                    .length,
                totalCount: viewModel.achievements.length,
              ),
              const SizedBox(height: 24),
              ...AchievementType.values.map((type) {
                final achievements = viewModel.getAchievementsByType(type);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _CategoryHeader(type: type),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        final progress = viewModel.getAchievementProgress(achievement);
                        return _AchievementCard(
                          achievement: achievement,
                          progress: progress,
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

class _PointsBanner extends StatelessWidget {
  final int totalPoints;
  final int unlockedCount;
  final int totalCount;

  const _PointsBanner({
    required this.totalPoints,
    required this.unlockedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$unlockedCount / $totalCount',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Puntos Totales',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '$totalPoints',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Lottie.asset(
            'assets/animations/badge.json',
            width: 80,
            height: 80,
            repeat: false,
          ),
        ],
      ),
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  final AchievementType type;

  const _CategoryHeader({required this.type});

  IconData get _icon {
    switch (type) {
      case AchievementType.MOOD_STREAK:
        return Icons.mood;
      case AchievementType.MEDITATION_TIME:
        return Icons.self_improvement;
      case AchievementType.SELF_CARE:
        return Icons.favorite;
    }
  }

  String get _title {
    switch (type) {
      case AchievementType.MOOD_STREAK:
        return 'Estado de Ánimo';
      case AchievementType.MEDITATION_TIME:
        return 'Meditación';
      case AchievementType.SELF_CARE:
        return 'Autocuidado';
    }
  }

  Color _getColor(BuildContext context) {
    switch (type) {
      case AchievementType.MOOD_STREAK:
        return Colors.amber;
      case AchievementType.MEDITATION_TIME:
        return Colors.blue;
      case AchievementType.SELF_CARE:
        return Colors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          _title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;
  final int progress;

  const _AchievementCard({
    required this.achievement,
    required this.progress,
  });

  Color _getLevelColor() {
    switch (achievement.level) {
      case 'BRONZE':
        return const Color(0xFFCD7F32);
      case 'SILVER':
        return const Color(0xFFC0C0C0);
      case 'GOLD':
        return const Color(0xFFFFD700);
      case 'DIAMOND':
        return const Color(0xFFB9F2FF);
      default:
        return Colors.grey;
    }
  }

  double _getProgressPercent() {
    if (achievement.requirement == 0) return 0;
    return (progress / achievement.requirement).clamp(0.0, 1.0);
  }

  String _formatProgress() {
    if (achievement.type == AchievementType.MEDITATION_TIME) {
      final hours = progress ~/ 60;
      final mins = progress % 60;
      if (hours > 0) {
        return '${hours}h ${mins}m';
      }
      return '${mins}m';
    }
    return '$progress';
  }

  String _formatRequirement() {
    if (achievement.type == AchievementType.MEDITATION_TIME) {
      final hours = achievement.requirement ~/ 60;
      final mins = achievement.requirement % 60;
      if (hours > 0) {
        return '${hours}h${mins > 0 ? ' ${mins}m' : ''}';
      }
      return '${mins}m';
    }
    return '${achievement.requirement}';
  }

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final levelColor = _getLevelColor();
    final progressPercent = _getProgressPercent();

    return Container(
      decoration: BoxDecoration(
        color: isUnlocked
            ? Theme.of(context).colorScheme.surface
            : Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? levelColor.withValues(alpha: 0.5)
              : Colors.grey.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? levelColor.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isUnlocked
                            ? LinearGradient(
                                colors: [levelColor, levelColor.withValues(alpha: 0.7)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isUnlocked ? null : Colors.grey.withValues(alpha: 0.2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Image.asset(
                          achievement.iconAsset,
                          fit: BoxFit.contain,
                          color: isUnlocked ? Colors.white : Colors.grey,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.emoji_events,
                            color: isUnlocked ? Colors.white : Colors.grey,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                    if (!isUnlocked)
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        child: const Icon(
                          Icons.lock,
                          color: Colors.white70,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      achievement.level,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: levelColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    achievement.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isUnlocked
                          ? Theme.of(context).textTheme.bodyLarge?.color
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 4),
                Flexible(
                  child: Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 10,
                      color: isUnlocked
                          ? Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7)
                          : Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                if (!isUnlocked) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatProgress(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      Text(
                        ' / ${_formatRequirement()}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: Colors.grey.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        levelColor.withValues(alpha: 0.7),
                      ),
                      minHeight: 4,
                    ),
                  ),
                ] else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          levelColor,
                          levelColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '+${achievement.points} pts',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (isUnlocked)
            Positioned(
              top: 6,
              right: 6,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: levelColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: levelColor.withValues(alpha: 0.4),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}