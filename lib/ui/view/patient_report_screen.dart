import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/patient_report_model.dart';
import '../../viewmodels/patient_report_view_model.dart';
import '../widgets/report_widgets.dart';

/// Screen that displays the detailed patient report
/// Includes complete analysis, recommendations and next steps
class PatientReportScreen extends StatelessWidget {
  final PatientReportModel report;

  const PatientReportScreen({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Salud Mental'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareReport(context),
            tooltip: 'Compartir reporte',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildRiskAndScoreSection(context),
            const SizedBox(height: 24),
            _buildExecutiveSummary(context),
            const SizedBox(height: 24),
            _buildSymptomAnalysis(context),
            const SizedBox(height: 24),
            _buildRecommendations(context),
            const SizedBox(height: 24),
            _buildSuggestedResources(context),
            const SizedBox(height: 24),
            _buildNextSteps(context),
            const SizedBox(height: 24),
            _buildAdditionalNotes(context),
            const SizedBox(height: 24),
            _buildReportMetadata(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    ),
    );
  }

  /// Builds the report header
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reporte de Evaluación',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Generado el ${_formatDate(report.createdAt)}',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the risk and score section
  Widget _buildRiskAndScoreSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Stack vertically on small screens
          return Column(
            children: [
              RiskLevelIndicator(
                riskLevel: report.riskLevel,
                showDescription: true,
              ),
              const SizedBox(height: 16),
              WellnessScoreWidget(
                score: report.wellnessScore,
                showDescription: true,
              ),
            ],
          );
        } else {
          // Use row on larger screens
          return Row(
            children: [
              Expanded(
                child: RiskLevelIndicator(
                  riskLevel: report.riskLevel,
                  showDescription: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: WellnessScoreWidget(
                  score: report.wellnessScore,
                  showDescription: true,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  /// Builds the executive summary section
  Widget _buildExecutiveSummary(BuildContext context) {
    return ReportCardWidget(
      title: 'Resumen Ejecutivo',
      icon: Icons.summarize,
      child: Text(
        report.executiveSummary,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Builds the symptom analysis section
  Widget _buildSymptomAnalysis(BuildContext context) {
    return ReportCardWidget(
      title: 'Análisis de Síntomas',
      icon: Icons.psychology,
      child: Text(
        report.symptomAnalysis,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Builds the recommendations section
  Widget _buildRecommendations(BuildContext context) {
    return ReportCardWidget(
      title: 'Recomendaciones',
      icon: Icons.lightbulb,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.recommendations.map((recommendation) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    recommendation,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the suggested resources section
  Widget _buildSuggestedResources(BuildContext context) {
    return ReportCardWidget(
      title: 'Recursos Sugeridos',
      icon: Icons.book,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: report.suggestedResources.map((resource) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.star_outline,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    resource,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Builds the next steps section
  Widget _buildNextSteps(BuildContext context) {
    return ReportCardWidget(
      title: 'Próximos Pasos',
      icon: Icons.directions_walk,
      child: Text(
        report.nextSteps,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Builds the additional notes section
  Widget _buildAdditionalNotes(BuildContext context) {
    if (report.additionalNotes.isEmpty) return const SizedBox.shrink();

    return ReportCardWidget(
      title: 'Notas Adicionales',
      icon: Icons.note,
      child: Text(
        report.additionalNotes,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.justify,
      ),
    );
  }

  /// Builds the report metadata section
  Widget _buildReportMetadata(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información del Reporte',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMetadataRow('ID del Reporte', report.id),
          _buildMetadataRow('Fecha de Creación', _formatDate(report.createdAt)),
          _buildMetadataRow('Última Actualización', _formatDate(report.lastUpdated)),
          _buildMetadataRow('Respuestas del Cuestionario', '${report.questionnaireAnswers.length} preguntas'),
        ],
      ),
    );
  }

  /// Builds a metadata row
  Widget _buildMetadataRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  /// Shares the report
  void _shareReport(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad de compartir próximamente'),
      ),
    );
  }
}

/// Screen that shows a list of all user reports
class PatientReportsListScreen extends StatefulWidget {
  const PatientReportsListScreen({super.key});

  @override
  State<PatientReportsListScreen> createState() => _PatientReportsListScreenState();
}

class _PatientReportsListScreenState extends State<PatientReportsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientReportViewModel>().loadUserReports();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Reportes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<PatientReportViewModel>().loadUserReports();
            },
            tooltip: 'Actualizar reportes',
          ),
        ],
      ),
      body: Consumer<PatientReportViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar los reportes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (!viewModel.hasReports) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes reportes aún',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Completa el cuestionario para generar tu primer reporte de salud mental',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => viewModel.refresh(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: viewModel.reports.length,
              itemBuilder: (context, index) {
                final report = viewModel.reports[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: viewModel.getRiskLevelColor(report.riskLevel),
                      child: Icon(
                        viewModel.getRiskLevelIcon(report.riskLevel),
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      'Reporte del ${viewModel.formatDate(report.createdAt)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nivel de Riesgo: ${report.riskLevel.displayName}'),
                        Text('Puntuación: ${report.wellnessScore}/100'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PatientReportScreen(report: report),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
