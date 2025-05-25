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
              // Total de puntos
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).colorScheme.secondary,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Puntos Totales',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '${viewModel.totalPoints}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Lottie.asset(
                      'assets/animations/badge.json',
                      width: 60,
                      height: 60,
                      repeat: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Achievements per category
              ...AchievementType.values.map((type) {
                final achievements = viewModel.getAchievementsByType(type);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getCategoryTitle(type),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: achievements.length,
                      itemBuilder: (context, index) {
                        final achievement = achievements[index];
                        return _AchievementCard(achievement: achievement);
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                );
              })
            ],
          );
        },
      ),
    );
  }

  String _getCategoryTitle(AchievementType type) {
    switch (type) {
      case AchievementType.MOOD_STREAK:
        return 'Estado de Ánimo';
      case AchievementType.MEDITATION_TIME:
        return 'Meditación';
      case AchievementType.SELF_CARE:
        return 'Autocuidado';
    }
  }
}

class _AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const _AchievementCard({
    required this.achievement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            
            
            Image.asset(
              achievement.iconAsset,
              width: 80,
              height: 80,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 12),
            
            // Título
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                achievement.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: achievement.isUnlocked
                      ? Theme.of(context).textTheme.bodyLarge?.color
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                achievement.description,
                style: TextStyle(
                  fontSize: 12,
                  color: achievement.isUnlocked
                      ? Theme.of(context).textTheme.bodyMedium?.color
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 8),
            
         
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: achievement.isUnlocked
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${achievement.points} pts',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),]
      ),
    );
  }
} 