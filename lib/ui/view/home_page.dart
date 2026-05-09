import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/ui/widgets/mood_lottie_container.dart';
import 'package:calm_mind/ui/widgets/breathing_button.dart';
import 'package:calm_mind/viewmodels/mood_view_model.dart';
import 'package:calm_mind/viewmodels/tips_view_model.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:calm_mind/services/haptics_service.dart';
import 'package:calm_mind/ui/view/coping_strategies_screen.dart';
import 'package:calm_mind/ui/view/emotions_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(builder: (context) => _HomePageMain());
      },
    );
  }
}

class _HomePageMain extends StatefulWidget {
  const _HomePageMain();

  @override
  State<_HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<_HomePageMain> {
  int _timeRemaining = 10;
  Timer? _timer;
  Random rng = Random();
  int randomNumber = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
        if (_timeRemaining <= 0) {
          _timer?.cancel();
          final tips = context.read<TipsViewModel>().tips;
          // BUG-04: Guard against empty tips list to avoid RangeError
          if (tips.isNotEmpty) {
            randomNumber = rng.nextInt(tips.length);
          }
          _timeRemaining = 10;
          _startTimer();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Icon(
              Icons.home,
              color:
                  Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
            ),
            toolbarHeight: 30,
            actions: [
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => openGlobalEndDrawer(context),
              ),
            ],
          ),

          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FadeInDown(
                            config: BaseAnimationConfig(
                              child: Text(
                                '¿Cómo te sientes ahora?',
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          FadeInLeft(
                            config: BaseAnimationConfig(
                              delay: 150.ms,
                              useScrollForAnimation: true,
                              child: _buildMoodStates(viewModel, context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            config: BaseAnimationConfig(
                              delay: 300.ms,
                              useScrollForAnimation: true,
                              child: _buildNewFeaturesSection(context),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            config: BaseAnimationConfig(
                              delay: 300.ms,
                              useScrollForAnimation: true,
                              child: _buildBreathingSection(context),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

Widget _buildMoodStates(MoodViewModel viewModel, BuildContext context) {
  var provider = Provider.of<MoodViewModel>(context);
  bool isLoading = provider.isLoading;
  return Column(
    children: [
      // Mood selection row
      Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                viewModel.selectedMood?.color ?? Theme.of(context).primaryColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children:
                  viewModel.availableMoods.map((mood) {
                    return WMoodLottieContainer(
                      mood: mood,
                      isSelected: viewModel.selectedMood == mood,
                      onTap: () {
                        viewModel.selectMood(mood);
                      },
                    );
                  }).toList(),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: TextField(
                enabled: viewModel.selectedMood != null,
                controller: viewModel.noteController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      viewModel.selectedMood != null
                          ? 'Agrega una nota de cómo te sientes (opcional)'
                          : 'Selecciona un estado de ánimo primero',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              spacing: 10,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                  child: ElevatedButton(
                    onPressed:
                        viewModel.selectedMood != null
                            ? () {
                              HapticsService.success();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Tu estado de ánimo ha sido guardado',
                                  ),
                                  duration: const Duration(seconds: 1),
                                  backgroundColor:
                                      viewModel.selectedMood?.color ??
                                      Colors.white,
                                ),
                              );
                              viewModel.saveMoodEntry();
                            }
                            : null,

                    child: const Text('Guardar '),
                  ),
                ),
                Flexible(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await context.read<MoodViewModel>().fetchMoodHistory(
                          context.read<UserViewModel>().currentUser.uid,
                        );

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EmotionsScreen(),
                          ),
                        );
                      } catch (e) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al cargar el historial: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child:
                        isLoading
                            ? Lottie.asset(
                              'assets/animations/loading.json',
                              width: 24,
                              height: 20,
                            )
                            : const Text('Historial'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ],
  );
}

Widget _buildTipCard(int randomNumber, int timeRemaining) {
  return Consumer<TipsViewModel>(
    builder: (context, viewModel, child) {
      final moodList = viewModel.tips;
      // BUG-04: Return empty widget if tips haven't loaded yet
      if (moodList.isEmpty) return const SizedBox.shrink();
      // Guard index against out-of-bounds after list changes
      final safeIndex = randomNumber.clamp(0, moodList.length - 1);
      final tip = moodList[safeIndex];
      final theme = Theme.of(context);

      return SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 1500),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOut,
                  reverseCurve: Curves.easeInOut,
                ),
                child: child,
              );
            },
child: Container(
              key: ValueKey<int>(randomNumber),
              padding: EdgeInsets.all(15),
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color:
                    Theme.of(context).brightness == Brightness.dark
                        ? Color(0xFF0D47A1).withValues(alpha: 0.6)
                        : Color(0xFFF0F4FF), // Lavender,

                boxShadow: [
                  BoxShadow(
                    offset: Offset(1, 5),
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tip.title,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          offset: Offset(1, 1),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(tip.content, style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildBreathingSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.1),
            Theme.of(context).primaryColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.air,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '¿Necesitas calmarte?',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Prueba la técnica de respiración 4-7-8',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Center(
            child: BreathingButton(
              size: 80,
              onComplete: () {},
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildNewFeaturesSection(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Herramientas',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: _FeatureCard(
            icon: Icons.psychology,
            title: 'Kit de Estrategias',
            subtitle: 'Herramientas personalizadas para ti',
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CopingStrategiesScreen()),
              );
            },
          ),
        ),
      ],
    ),
  );
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
