import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'patients_list_screen.dart';
import '../../../models/professional_patient_model.dart';
import '../../../viewmodels/professional_patient_view_model.dart';
import '../../../viewmodels/patient_report_view_model.dart';

/// Screen that shows professional statistics and analytics
/// Displays patient data, report analytics, and performance metrics
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    // Load data after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  /// Loads all necessary data
  Future<void> _loadData() async {
    if (!mounted) return;

    final patientViewModel = context.read<ProfessionalPatientViewModel>();
    try {
      print('Loading data in statistics screen...');
      await patientViewModel.loadPatients();
      await patientViewModel.loadStatistics();
      print('Data loaded successfully');
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Estadísticas'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
            tooltip: 'Actualizar datos',
          ),
        ],
      ),
      body: Consumer<ProfessionalPatientViewModel>(
        builder: (context, patientViewModel, child) {
          if (patientViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (patientViewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar estadísticas',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    patientViewModel.errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _loadData();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildOverviewCards(patientViewModel),
                const SizedBox(height: 24),
                _buildPatientStatusChart(patientViewModel),
                const SizedBox(height: 24),
                _buildRecentActivity(patientViewModel),
                const SizedBox(height: 24),
                _buildReportsAnalytics(),
                const SizedBox(height: 24),
                _buildPerformanceMetrics(patientViewModel),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the overview cards
  Widget _buildOverviewCards(ProfessionalPatientViewModel viewModel) {
    final stats = viewModel.statistics ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Resumen General',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.2,
          children: [
            _buildStatCard(
              title: 'Total Pacientes',
              value: '${stats['totalPatients'] ?? 0}',
              icon: Icons.people,
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PatientsListScreen(),
                  ),
                );
              },
            ),
            _buildStatCard(
              title: 'Activos',
              value: '${stats['activePatients'] ?? 0}',
              icon: Icons.check_circle,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PatientsListScreen(
                          statusFilter: PatientStatus.active,
                        ),
                  ),
                );
              },
            ),
            _buildStatCard(
              title: 'Inactivos',
              value: '${stats['inactivePatients'] ?? 0}',
              icon: Icons.pause_circle,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PatientsListScreen(
                          statusFilter: PatientStatus.inactive,
                        ),
                  ),
                );
              },
            ),
            _buildStatCard(
              title: 'Dados de Alta',
              value: '${stats['dischargedPatients'] ?? 0}',
              icon: Icons.cancel,
              color: Colors.red,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => const PatientsListScreen(
                          statusFilter: PatientStatus.discharged,
                        ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  /// Builds a statistics card
  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: color, size: 20),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the patient status chart
  Widget _buildPatientStatusChart(ProfessionalPatientViewModel viewModel) {
    final stats = viewModel.statistics ?? {};
    final total = (stats['totalPatients'] ?? 0) as int;

    if (total == 0) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No hay datos para mostrar',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Agrega pacientes para ver estadísticas',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.pie_chart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Distribución de Pacientes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusBar(
              'Activos',
              stats['activePatients'] ?? 0,
              total,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildStatusBar(
              'Inactivos',
              stats['inactivePatients'] ?? 0,
              total,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildStatusBar(
              'Dados de Alta',
              stats['dischargedPatients'] ?? 0,
              total,
              Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a status bar
  Widget _buildStatusBar(String label, int value, int total, Color color) {
    final percentage = total > 0 ? (value / total) * 100 : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '$value (${percentage.toStringAsFixed(1)}%)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }

  /// Builds the recent activity section
  Widget _buildRecentActivity(ProfessionalPatientViewModel viewModel) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timeline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Actividad Reciente',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActivityItem(
              icon: Icons.people,
              title: 'Total de Pacientes',
              subtitle: '${viewModel.patients.length} pacientes en tu lista',
              color: Colors.blue,
            ),
            const SizedBox(height: 12),
            Consumer<PatientReportViewModel>(
              builder: (context, reportViewModel, child) {
                return _buildActivityItem(
                  icon: Icons.assessment,
                  title: 'Reportes Generados',
                  subtitle:
                      '${reportViewModel.reports.length} reportes disponibles',
                  color: Colors.green,
                );
              },
            ),
            const SizedBox(height: 12),
            _buildActivityItem(
              icon: Icons.event,
              title: 'Consultas Programadas',
              subtitle: 'Próximas consultas con pacientes',
              color: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an activity item
  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the reports analytics section
  Widget _buildReportsAnalytics() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Análisis de Reportes',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.assessment_outlined,
                    size: 48,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Análisis de Reportes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los reportes se analizan automáticamente cuando los pacientes los generan',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the performance metrics section
  Widget _buildPerformanceMetrics(ProfessionalPatientViewModel viewModel) {
    final stats = viewModel.statistics ?? {};

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Métricas de Rendimiento',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (stats['averageAge'] != null && stats['averageAge'] > 0) ...[
              _buildMetricItem(
                'Edad Promedio de Pacientes',
                '${stats['averageAge']} años',
                Icons.cake,
                Colors.purple,
              ),
              const SizedBox(height: 12),
            ],
            _buildMetricItem(
              'Tasa de Pacientes Activos',
              '${_calculateActiveRate(stats)}%',
              Icons.check_circle,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildMetricItem(
              'Total de Pacientes',
              '${stats['totalPatients'] ?? 0}',
              Icons.people,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a metric item
  Widget _buildMetricItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  /// Calculates the active patient rate
  double _calculateActiveRate(Map<String, dynamic> stats) {
    final total = (stats['totalPatients'] ?? 0) as int;
    final active = (stats['activePatients'] ?? 0) as int;
    return total > 0 ? (active / total) * 100 : 0.0;
  }
}
