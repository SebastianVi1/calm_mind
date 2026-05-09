import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/models/mood_model.dart';
import 'package:calm_mind/ui/constants/animation_constants.dart';
import 'package:calm_mind/ui/widgets/emotion_weather_map.dart';
import 'package:calm_mind/viewmodels/mood_view_model.dart';
import 'package:calm_mind/services/ai/i_ai_service.dart';
import 'package:calm_mind/services/haptics_service.dart';
import 'package:intl/intl.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Set<String> _selectedFilter = {'todos'};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.book,
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Mi Diario',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.15),
                theme.scaffoldBackgroundColor,
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showWeeklyInsight(context),
            icon: Icon(Icons.auto_awesome, color: theme.colorScheme.primary),
            tooltip: 'Insight semanal',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.edit_note), text: 'Historial'),
            Tab(icon: Icon(Icons.insights), text: 'Estadísticas'),
          ],
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurface.withValues(
            alpha: 0.6,
          ),
          indicatorColor: theme.colorScheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _HistoryTab(
            selectedFilter: _selectedFilter,
            onFilterChanged:
                (filter) => setState(() => _selectedFilter = {filter}),
          ),
          _StatsTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewEntryDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Nueva entrada'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
      ),
    );
  }

  void _showNewEntryDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    final viewModel = context.read<MoodViewModel>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NewEntryBottomSheet(viewModel: viewModel),
    );
  }

  void _showWeeklyInsight(BuildContext context) async {
    HapticFeedback.lightImpact();
    final viewModel = context.read<MoodViewModel>();
    final aiService = context.read<IAIService>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Lottie.asset(
                    'assets/animations/loading.json',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Generando insight semanal...'),
              ],
            ),
          ),
    );

    final insight = await viewModel.generateWeeklyInsight(aiService);
    if (context.mounted) {
      Navigator.pop(context);
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  const Text('Insight Semanal'),
                ],
              ),
              content: SingleChildScrollView(
                child: Text(
                  insight,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.6),
                ),
              ),
              actions: [
                FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Entendido'),
                ),
              ],
            ),
      );
    }
  }
}

class _HistoryTab extends StatelessWidget {
  final Set<String> selectedFilter;
  final Function(String) onFilterChanged;

  const _HistoryTab({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MoodViewModel>();

    if (viewModel.moodHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset(
                  'assets/animations/meditation.json',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Sin entradas aún',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Registra tu primer estado de ánimo para comenzar tu diario emocional',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).padding.top + kToolbarHeight),
        const SizedBox(height: 2),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'hoy',
                label: Text('Hoy'),
                icon: Icon(Icons.today),
              ),
              ButtonSegment(
                value: 'semanal',
                label: Text('Semanal'),
                icon: Icon(Icons.calendar_view_week),
              ),
              ButtonSegment(
                value: 'todos',
                label: Text('Todos'),
                icon: Icon(Icons.calendar_month),
              ),
            ],
            selected: selectedFilter,
            onSelectionChanged: (Set<String> newSelection) {
              HapticsService.selection();
              onFilterChanged(newSelection.first);
            },
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Consumer<MoodViewModel>(
            builder: (context, viewModel, child) {
              final filteredMoods = viewModel.filterMoods(selectedFilter.first);

              if (filteredMoods.isEmpty) {
                return Center(
                  child: Text(
                    'No hay entradas para este período',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredMoods.length,
                itemBuilder: (context, index) {
                  final mood = filteredMoods[index];
                  return FadeInUp(
                    config: BaseAnimationConfig(
                      delay: (index * 50).ms,
                      child: _MoodEntryCard(mood: mood),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MoodEntryCard extends StatelessWidget {
  final MoodModel mood;

  const _MoodEntryCard({required this.mood});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasContent = mood.content != null && mood.content!.isNotEmpty;
    final hasNote = mood.note != null && mood.note!.isNotEmpty;
    final hasAnalysis = mood.aiAnalysis != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: InkWell(
        onTap: () => _showMoodDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: mood.color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Lottie.asset(
                      mood.lottieAsset,
                      width: 32,
                      height: 32,
                      animate: false,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mood.label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: mood.color,
                          ),
                        ),
                        Text(
                          DateFormat(
                            'dd MMM yyyy • HH:mm',
                          ).format(mood.timestamp),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (hasAnalysis)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getSentimentColor(
                          mood.aiAnalysis!.sentimentScore,
                        ).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getSentimentIcon(mood.aiAnalysis!.sentimentScore),
                            size: 14,
                            color: _getSentimentColor(
                              mood.aiAnalysis!.sentimentScore,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${mood.aiAnalysis!.sentimentScore}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: _getSentimentColor(
                                mood.aiAnalysis!.sentimentScore,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              if (hasNote) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    mood.note!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
              if (hasContent) ...[
                const SizedBox(height: 12),
                Text(
                  mood.content!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (hasAnalysis) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 16,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Análisis de IA',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        mood.aiAnalysis!.summary,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      if (mood.aiAnalysis!.tags.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children:
                              mood.aiAnalysis!.tags.map((tag) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    tag,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodDetail(BuildContext context) {
    final theme = Theme.of(context);
    HapticFeedback.lightImpact();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Expanded(
                      child: ListView(
                        controller: scrollController,
                        padding: const EdgeInsets.all(24),
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: mood.color.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Lottie.asset(
                                  mood.lottieAsset,
                                  width: 48,
                                  height: 48,
                                  animate: false,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    mood.label,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: mood.color,
                                        ),
                                  ),
                                  Text(
                                    DateFormat(
                                      'EEEE, dd MMMM yyyy • HH:mm',
                                    ).format(mood.timestamp),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (mood.note != null && mood.note!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Nota',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                mood.note!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                          if (mood.content != null &&
                              mood.content!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Diario',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              mood.content!,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.8,
                                color: theme.colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ],
                          if (mood.aiAnalysis != null) ...[
                            const SizedBox(height: 24),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    theme.colorScheme.primary.withValues(
                                      alpha: 0.05,
                                    ),
                                    theme.colorScheme.secondary.withValues(
                                      alpha: 0.05,
                                    ),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_awesome,
                                        color: theme.colorScheme.primary,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Análisis de IA',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      _SentimentChip(
                                        label: 'Sentimiento',
                                        value: mood.aiAnalysis!.sentimentScore,
                                        icon: _getSentimentIcon(
                                          mood.aiAnalysis!.sentimentScore,
                                        ),
                                        color: _getSentimentColor(
                                          mood.aiAnalysis!.sentimentScore,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    mood.aiAnalysis!.summary,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      height: 1.6,
                                    ),
                                  ),
                                  if (mood.aiAnalysis!.tags.isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      children:
                                          mood.aiAnalysis!.tags.map((tag) {
                                            return Chip(
                                              label: Text(tag),
                                              backgroundColor: theme
                                                  .colorScheme
                                                  .primary
                                                  .withValues(alpha: 0.1),
                                              labelStyle: TextStyle(
                                                color:
                                                    theme.colorScheme.primary,
                                                fontSize: 12,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                            );
                                          }).toList(),
                                    ),
                                  ],
                                  if (mood.aiAnalysis!.insights.isNotEmpty) ...[
                                    const SizedBox(height: 16),
                                    Text(
                                      'Insights',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...mood.aiAnalysis!.insights.map((insight) {
                                      return Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 8,
                                        ),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '💡 ${insight.insight}',
                                              style: theme.textTheme.bodyMedium
                                                  ?.copyWith(height: 1.5),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '✅ ${insight.suggestion}',
                                              style: theme.textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        theme
                                                            .colorScheme
                                                            .primary,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Color _getSentimentColor(int score) {
    if (score >= 3) return Colors.green;
    if (score >= 0) return Colors.orange;
    return Colors.red;
  }

  IconData _getSentimentIcon(int score) {
    if (score >= 3) return Icons.sentiment_very_satisfied;
    if (score >= 0) return Icons.sentiment_neutral;
    return Icons.sentiment_very_dissatisfied;
  }
}

class _SentimentChip extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SentimentChip({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            '$label: $value',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _StatsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final viewModel = context.watch<MoodViewModel>();

    if (viewModel.moodHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Sin datos estadísticos',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + kToolbarHeight + 2,
        16,
        16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMoodChart(context, viewModel),
          const SizedBox(height: 16),
          _buildStreakCard(context, viewModel),
          const SizedBox(height: 16),
          _buildMoodDistribution(context, viewModel),
          const SizedBox(height: 16),
          _buildWeatherCalendar(context),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, MoodViewModel viewModel) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${viewModel.streakDays}',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              Text(
                'días',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMoodDistribution(BuildContext context, MoodViewModel viewModel) {
    final theme = Theme.of(context);
    final distribution = viewModel.logicPieChart(viewModel);

    if (distribution.isEmpty) return const SizedBox.shrink();

    final moodColors = {
      'happy': Colors.blue,
      'neutral': Colors.green,
      'angry': Colors.orange,
      'sad': Colors.grey,
    };

    final moodLabels = {
      'happy': 'Feliz',
      'neutral': 'Neutral',
      'angry': 'Enojado',
      'sad': 'Triste',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.pie_chart, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Distribución de Emociones',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...distribution.entries.map((entry) {
            final percentage = viewModel.porcentage(entry.key);
            final color = moodColors[entry.key] ?? Colors.grey;
            final label = moodLabels[entry.key] ?? entry.key;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${percentage.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: color.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMoodChart(BuildContext context, MoodViewModel viewModel) {
    final theme = Theme.of(context);
    final chartData = viewModel.getMoodChartData();

    if (chartData.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Tendencia de Ánimo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        String text = '';
                        if (value == 1) text = '😢';
                        if (value == 2) text = '😠';
                        if (value == 3) text = '😐';
                        if (value == 4) text = '😊';
                        return Text(text, style: const TextStyle(fontSize: 16));
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: theme.textTheme.bodySmall,
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 31,
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: chartData,
                    isCurved: true,
                    color: theme.colorScheme.primary,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) {
                        return FlDotCirclePainter(
                          radius: 4,
                          color: theme.colorScheme.primary,
                          strokeWidth: 2,
                          strokeColor: Colors.white,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCalendar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_month,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Calendario del Mes',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const EmotionWeatherMap(),
        ],
      ),
    );
  }
}

class _NewEntryBottomSheet extends StatefulWidget {
  final MoodViewModel viewModel;

  const _NewEntryBottomSheet({required this.viewModel});

  @override
  State<_NewEntryBottomSheet> createState() => _NewEntryBottomSheetState();
}

class _NewEntryBottomSheetState extends State<_NewEntryBottomSheet> {
  final TextEditingController _contentController = TextEditingController();
  String? _selectedMoodLabel;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.book, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Nueva entrada',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '¿Cómo te sientes?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children:
                        widget.viewModel.availableMoods.map((mood) {
                          final isSelected = _selectedMoodLabel == mood.label;
                          return AnimatedScale(
                            scale: isSelected ? 1.1 : 1.0,
                            duration: AppAnimations.short,
                            child: ChoiceChip(
                              avatar: Lottie.asset(
                                mood.lottieAsset,
                                width: 24,
                                height: 24,
                                animate: false,
                              ),
                              label: Text(mood.label),
                              selected: isSelected,
                              onSelected: (selected) {
                                HapticsService.selection();
                                setState(() {
                                  _selectedMoodLabel =
                                      selected ? mood.label : null;
                                });
                              },
                              selectedColor: mood.color.withValues(alpha: 0.2),
                              labelStyle: TextStyle(
                                color:
                                    isSelected
                                        ? mood.color
                                        : theme.colorScheme.onSurface,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Escribe sobre tu día (opcional)',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _contentController,
                    maxLines: 8,
                    decoration: InputDecoration(
                      hintText: '¿Cómo fue tu día? ¿Qué pensamientos tienes?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: theme.colorScheme.outline.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceVariant.withValues(
                        alpha: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed:
                          _selectedMoodLabel == null
                              ? null
                              : () async {
                                HapticFeedback.mediumImpact();
                                final aiService = context.read<IAIService>();
                                final entry = await widget.viewModel
                                    .saveMoodEntryAsync(
                                      content:
                                          _contentController.text.isNotEmpty
                                              ? _contentController.text
                                              : null,
                                      moodLabel: _selectedMoodLabel,
                                    );

                                if (mounted) {
                                  Navigator.pop(context);

                                  if (_contentController.text.isNotEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Guardando y analizando...',
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    );

                                    await widget.viewModel.analyzeMoodEntry(
                                      entry.moodId!,
                                      aiService,
                                    );

                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Análisis completado'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Estado de ánimo guardado',
                                        ),
                                        backgroundColor:
                                            theme.colorScheme.primary,
                                      ),
                                    );
                                  }
                                }
                              },
                      icon:
                          widget.viewModel.isAnalyzing
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                              : const Icon(Icons.save),
                      label: Text(
                        widget.viewModel.isAnalyzing
                            ? 'Analizando...'
                            : 'Guardar y analizar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
