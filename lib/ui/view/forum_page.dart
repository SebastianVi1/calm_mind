import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/forum_post.dart';
import 'package:calm_mind/ui/view/meditation_picker.dart';
import 'package:calm_mind/ui/view/relaxing_music_picker.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/ui/widgets/skeleton_loader.dart';
import 'package:calm_mind/viewmodels/forum_view_model.dart';

class ForumPage extends StatelessWidget {
  const ForumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _SliverForumHeader(isDark: isDark),
          SliverToBoxAdapter(child: _buildDailyCheckIn(context)),
          SliverToBoxAdapter(child: _buildQuickAccessRow(context)),
          SliverToBoxAdapter(
            child: _buildSectionTitle(context, 'Desafíos Grupales'),
          ),
          SliverToBoxAdapter(child: _buildChallengesRow(context)),
          SliverToBoxAdapter(child: _buildSectionTitle(context, 'Comunidad')),
          _buildPostsSection(context),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

class _SliverForumHeader extends StatelessWidget {
  final bool isDark;
  const _SliverForumHeader({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      title: Row(
        children: [
          const Icon(Icons.forum, size: 24),
          const SizedBox(width: 8),
          Text(
            'Comunidad',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => openGlobalEndDrawer(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AnimatedContainer(
              duration: const Duration(seconds: 3),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      isDark
                          ? [const Color(0xFF2D1B69), const Color(0xFF1A1A2E)]
                          : [const Color(0xFF8EACCD), const Color(0xFFC3E8B3)],
                ),
              ),
            ),
            CustomPaint(
              painter: _WavePainter(isDark: isDark),
              size: Size.infinite,
            ),
          ],
        ),
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  final bool isDark;
  _WavePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02),
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.6);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.45,
      size.width * 0.5,
      size.height * 0.55,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.65,
      size.width,
      size.height * 0.5,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    final paint2 =
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromLTWH(0, size.height * 0.5, size.width, size.height * 0.5),
          );

    final path2 = Path();
    path2.moveTo(0, size.height * 0.8);
    path2.quadraticBezierTo(
      size.width * 0.3,
      size.height * 0.72,
      size.width * 0.6,
      size.height * 0.78,
    );
    path2.quadraticBezierTo(
      size.width * 0.8,
      size.height * 0.82,
      size.width,
      size.height * 0.76,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Widget _buildDailyCheckIn(BuildContext context) {
  final theme = Theme.of(context);

  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Consumer<ForumViewModel>(
      builder: (context, vm, child) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.wb_sunny,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '¿Cómo te sientes hoy?',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ['Feliz', 'Neutral', 'Enojado', 'Triste'].map((mood) {
                        final isSelected = vm.checkInMood == mood;
                        final moodColors = {
                          'Feliz': Colors.amber,
                          'Neutral': Colors.blue,
                          'Enojado': Colors.red,
                          'Triste': Colors.indigo,
                        };
                        final color = moodColors[mood]!;
                        return ChoiceChip(
                          label: Text(mood),
                          selected: isSelected,
                          onSelected:
                              (_) => vm.setCheckInMood(isSelected ? '' : mood),
                          selectedColor: color.withValues(alpha: 0.2),
                          backgroundColor: theme.colorScheme.surfaceVariant
                              .withValues(alpha: 0.5),
                          labelStyle: TextStyle(
                            color:
                                isSelected
                                    ? color
                                    : theme.colorScheme.onSurface,
                            fontWeight:
                                isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? color : Colors.transparent,
                          ),
                        );
                      }).toList(),
                ),
                if (vm.checkInMood.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: vm.postController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            hintText: 'Comparte algo con la comunidad...',
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.4,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: theme.colorScheme.surfaceVariant
                                .withValues(alpha: 0.4),
                            contentPadding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: () {
                          HapticFeedback.mediumImpact();
                          vm.addPost();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Publicado en la comunidad'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        icon: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    ),
  );
}

Widget _buildSectionTitle(BuildContext context, String title) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Row(
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget _buildQuickAccessRow(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: SizedBox(
      height: 140,
      child: Row(
        children: [
          Expanded(
            child: _QuickAccessCard(
              icon: Icons.headphones,
              title: 'Música\nRelajante',
              gradientColors: [Colors.purple, Colors.deepOrange],
              lottieAsset: 'assets/animations/music_hearing.json',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RelaxingMusicPicker()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _QuickAccessCard(
              icon: Icons.self_improvement,
              title: 'Meditación\nGuiada',
              gradientColors: [const Color(0xFFD8B5FF), const Color(0xFF1EAE98)],
              lottieAsset: 'assets/animations/focus_brain.json',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MeditationPicker()),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _QuickAccessCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> gradientColors;
  final String lottieAsset;
  final VoidCallback onTap;

  const _QuickAccessCard({
    required this.icon,
    required this.title,
    required this.gradientColors,
    required this.lottieAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          boxShadow: [
            BoxShadow(
              color: gradientColors.first.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -15,
              top: -10,
              child: Opacity(
                opacity: 0.7,
                child: Lottie.asset(lottieAsset, width: 90),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: Colors.white, size: 18),
                  ),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildChallengesRow(BuildContext context) {
  return SizedBox(
    height: 150,
    child: Consumer<ForumViewModel>(
      builder: (context, vm, child) {
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: vm.challenges.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final challenge = vm.challenges[index];
            return SizedBox(
              width: 200,
              child: Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            challenge.emoji,
                            style: const TextStyle(fontSize: 28),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${challenge.randomParticipants} 🧑‍🤝‍🧑',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        challenge.title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        challenge.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}

Widget _buildPostsSection(BuildContext context) {
  return Consumer<ForumViewModel>(
    builder: (context, vm, child) {
      if (vm.posts.isEmpty) {
        return SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(children: [WSkeleton.card()]),
            ),
          ),
        );
      }

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _PostCard(
            post: vm.posts[index],
            onLike: () => vm.toggleLike(index),
            index: index,
          ),
          childCount: vm.posts.length,
        ),
      );
    },
  );
}

class _PostCard extends StatelessWidget {
  final ForumPost post;
  final VoidCallback onLike;
  final int index;

  const _PostCard({
    required this.post,
    required this.onLike,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: theme.colorScheme.primary.withValues(
                      alpha: 0.2,
                    ),
                    child: Text(
                      post.displayName[0].toUpperCase(),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                post.displayName,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${post.timeAgo} · ${post.moodEmoji}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                post.content,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onLike();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likeCount}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


