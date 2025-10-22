import 'package:flutter/material.dart';
import '../../models/patient_report_model.dart';

/// Widget that displays a report card with title, icon and content
class ReportCardWidget extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Color? iconColor;

  const ReportCardWidget({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: iconColor ?? Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// Widget that shows the risk level indicator
class RiskLevelIndicator extends StatelessWidget {
  final RiskLevel riskLevel;
  final bool showDescription;

  const RiskLevelIndicator({
    super.key,
    required this.riskLevel,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getRiskLevelColor(riskLevel);
    final icon = _getRiskLevelIcon(riskLevel);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Nivel de Riesgo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              riskLevel.displayName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (showDescription) ...[
              const SizedBox(height: 8),
              Text(
                _getRiskLevelDescription(riskLevel),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getRiskLevelColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  IconData _getRiskLevelIcon(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  String _getRiskLevelDescription(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return 'Indicadores positivos de bienestar mental';
      case RiskLevel.medium:
        return 'Algunas áreas requieren atención';
      case RiskLevel.high:
        return 'Requiere atención inmediata';
    }
  }
}

/// Widget that shows the wellness score
class WellnessScoreWidget extends StatelessWidget {
  final int score;
  final bool showDescription;

  const WellnessScoreWidget({
    super.key,
    required this.score,
    this.showDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getScoreColor(score);
    final description = _getScoreDescription(score);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite, color: color, size: 24),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Puntuación de Bienestar',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$score/100',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (showDescription) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  String _getScoreDescription(int score) {
    if (score >= 70) return 'Excelente bienestar mental';
    if (score >= 40) return 'Bienestar moderado';
    return 'Requiere atención';
  }
}

/// Widget que muestra un indicador de progreso circular personalizado
class CustomCircularProgressIndicator extends StatelessWidget {
  final double value;
  final Color? color;
  final double size;
  final double strokeWidth;

  const CustomCircularProgressIndicator({
    super.key,
    required this.value,
    this.color,
    this.size = 100,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: value,
            color: color ?? Theme.of(context).colorScheme.primary,
            strokeWidth: strokeWidth,
          ),
          Center(
            child: Text(
              '${(value * 100).round()}%',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget que muestra estadísticas de reportes
class ReportStatisticsWidget extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const ReportStatisticsWidget({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildStatRow(
              context,
              'Total de Reportes',
              '${statistics['totalReports']}',
              Icons.assessment,
            ),
            _buildStatRow(
              context,
              'Puntuación Promedio',
              '${statistics['averageWellnessScore']}/100',
              Icons.trending_up,
            ),
            _buildStatRow(
              context,
              'Último Reporte',
              _formatDate(statistics['latestReportDate']),
              Icons.calendar_today,
            ),
            const SizedBox(height: 12),
            _buildRiskDistribution(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskDistribution(BuildContext context) {
    final distribution = statistics['riskLevelDistribution'] as Map<String, int>;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Distribución de Riesgo',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...distribution.entries.map((entry) {
          final riskLevel = entry.key;
          final count = entry.value;
          final color = _getRiskLevelColor(riskLevel);
          
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${riskLevel.toUpperCase()}: $count',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Color _getRiskLevelColor(String riskLevel) {
    switch (riskLevel.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return 'N/A';
  }
}
