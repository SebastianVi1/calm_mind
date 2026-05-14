import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/viewmodels/coping_strategies_viewmodel.dart';
import 'package:calm_mind/models/coping_strategy_model.dart';

class CopingStrategiesScreen extends StatelessWidget {
  const CopingStrategiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kit de Estrategias'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context),
            tooltip: 'Historial',
          ),
        ],
      ),
      body: Consumer<CopingStrategiesViewModel>(
        builder: (context, viewModel, _) {
          return Column(
            children: [
              _buildMoodSelector(context, viewModel),
              Expanded(
                child: _buildStrategiesList(context, viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMoodSelector(BuildContext context, CopingStrategiesViewModel viewModel) {
    final moods = [
      {'label': 'Ansioso', 'emoji': '😰'},
      {'label': 'Triste', 'emoji': '😢'},
      {'label': 'Enojado', 'emoji': '😠'},
      {'label': 'Neutral', 'emoji': '😐'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Cómo te sientes ahora?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: moods.map((mood) {
              final isSelected = viewModel.currentMood == mood['label'];
              return ChoiceChip(
                avatar: Text(mood['emoji']!, style: const TextStyle(fontSize: 16)),
                label: Text(mood['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  viewModel.setCurrentMood(selected ? mood['label'] : null);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStrategiesList(BuildContext context, CopingStrategiesViewModel viewModel) {
    final strategies = viewModel.recommendedStrategies;

    if (strategies.isEmpty) {
      return Center(
        child: Text(
          viewModel.currentMood != null
              ? 'No hay estrategias específicas para este estado'
              : 'Selecciona cómo te sientes para ver recomendaciones',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: strategies.length,
      itemBuilder: (context, index) {
        final strategy = strategies[index];
        return _StrategyCard(strategy: strategy);
      },
    );
  }

  void _showHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Consumer<CopingStrategiesViewModel>(
              builder: (context, viewModel, _) {
                return ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Historial de Sesiones',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _StatBox(
                            value: '${viewModel.totalSessions}',
                            label: 'Total',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _StatBox(
                            value: '${viewModel.completedSessions}',
                            label: 'Completadas',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (viewModel.sessions.isEmpty)
                      const Center(child: Text('No hay sesiones aún'))
                    else
                      ...viewModel.sessions.take(20).map((session) {
                        final strategy = viewModel.strategies.firstWhere(
                          (s) => s.id == session.strategyId,
                          orElse: () => CopingStrategy(
                            id: session.strategyId,
                            title: 'Estrategia',
                            description: '',
                            type: CopingStrategyType.MINDFULNESS,
                            icon: '🧘',
                            durationMinutes: 0,
                            steps: [],
                            forMoods: [],
                          ),
                        );
                        return ListTile(
                          leading: Text(strategy.icon, style: const TextStyle(fontSize: 24)),
                          title: Text(strategy.title),
                          subtitle: Text(
                            '${_formatDate(session.timestamp)} - ${session.completedSteps}/${session.totalSteps} pasos',
                          ),
                          trailing: Icon(
                            session.isCompleted ? Icons.check_circle : Icons.pending,
                            color: session.isCompleted ? Colors.green : Colors.orange,
                          ),
                        );
                      }).toList(),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Ahora';
    if (diff.inHours < 1) return 'Hace ${diff.inMinutes} min';
    if (diff.inDays < 1) return 'Hace ${diff.inHours}h';
    return '${date.day}/${date.month}';
  }
}

class _StrategyCard extends StatelessWidget {
  final CopingStrategy strategy;

  const _StrategyCard({required this.strategy});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _startStrategy(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(strategy.icon, style: const TextStyle(fontSize: 32)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      strategy.description,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${strategy.durationMinutes} min',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.format_list_numbered, size: 14, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 4),
                        Text(
                          '${strategy.steps.length} pasos',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _startStrategy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StrategyExecutionScreen(strategy: strategy),
      ),
    );
  }
}

class StrategyExecutionScreen extends StatefulWidget {
  final CopingStrategy strategy;

  const StrategyExecutionScreen({super.key, required this.strategy});

  @override
  State<StrategyExecutionScreen> createState() => _StrategyExecutionScreenState();
}

class _StrategyExecutionScreenState extends State<StrategyExecutionScreen> {
  int _currentStep = 0;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    context.read<CopingStrategiesViewModel>().startSession(widget.strategy.id);
  }

  @override
  Widget build(BuildContext context) {
    final progress = (_currentStep + 1) / widget.strategy.steps.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.strategy.title),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              widget.strategy.icon,
              style: const TextStyle(fontSize: 64),
            ),
            const SizedBox(height: 16),
            Text(
              widget.strategy.description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
              minHeight: 8,
            ),
            const SizedBox(height: 8),
            Text(
              'Paso ${_currentStep + 1} de ${widget.strategy.steps.length}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.strategy.steps[_currentStep],
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        setState(() => _currentStep--);
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Anterior'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_currentStep < widget.strategy.steps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        setState(() => _isCompleted = true);
                        context.read<CopingStrategiesViewModel>().updateProgress(
                              widget.strategy.id,
                              widget.strategy.steps.length,
                            );
                      }
                    },
                    icon: Icon(_currentStep < widget.strategy.steps.length - 1
                        ? Icons.arrow_forward
                        : Icons.check),
                    label: Text(_currentStep < widget.strategy.steps.length - 1
                        ? 'Siguiente'
                        : 'Completar'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;

  const _StatBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
