import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/professional_patient_view_model.dart';
import '../../../viewmodels/patient_report_view_model.dart';
import '../../../models/professional_patient_model.dart';
import '../../../models/patient_report_model.dart';
import '../../view/patient_report_screen.dart';

/// Screen that shows detailed information about a patient
/// Includes patient info, reports, and management options
class PatientDetailScreen extends StatefulWidget {
  final ProfessionalPatientModel patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Cargar reportes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  Future<void> _loadPatientData() async {
    try {
      print('Loading patient data for: ${widget.patient.userId}');
      final reportViewModel = Provider.of<PatientReportViewModel>(
        context,
        listen: false,
      );
      await reportViewModel.loadUserReportsByUserId(widget.patient.userId);
      print('Reports loaded: ${reportViewModel.reports.length}');
      if (mounted) setState(() {});
    } catch (e) {
      print('Error loading patient data: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Loads patient reports
  Future<void> _loadPatientReports() async {
    final reportViewModel = Provider.of<PatientReportViewModel>(
      context,
      listen: false,
    );
    await reportViewModel.loadUserReportsByUserId(widget.patient.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.name),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar Información'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'status',
                    child: ListTile(
                      leading: Icon(Icons.swap_horiz),
                      title: Text('Cambiar Estado'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'consultation',
                    child: ListTile(
                      leading: Icon(Icons.event),
                      title: Text('Registrar Consulta'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'remove',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: Colors.red),
                      title: Text(
                        'Eliminar Paciente',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.onPrimary,
          labelColor: Theme.of(context).colorScheme.onPrimary,
          unselectedLabelColor: Theme.of(
            context,
          ).colorScheme.onPrimary.withOpacity(0.7),
          tabs: const [
            Tab(icon: Icon(Icons.info), text: 'Información'),
            Tab(icon: Icon(Icons.assessment), text: 'Reportes'),
            Tab(icon: Icon(Icons.timeline), text: 'Historial'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPatientInfoTab(),
          _buildReportsTab(),
          _buildHistoryTab(),
        ],
      ),
    );
  }

  /// Builds the patient information tab
  Widget _buildPatientInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPatientCard(),
          const SizedBox(height: 16),
          _buildPersonalInfoCard(),
          const SizedBox(height: 16),
          _buildProfessionalNotesCard(),
          const SizedBox(height: 16),
          _buildMedicalHistoryCard(),
        ],
      ),
    );
  }

  /// Builds the reports tab
  Widget _buildReportsTab() {
    return Consumer<PatientReportViewModel>(
      builder: (context, reportViewModel, child) {
        print(
          'Building reports tab. Reports count: ${reportViewModel.reports.length}',
        );

        if (reportViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (reportViewModel.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assessment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text('No hay reportes disponibles'),
                ElevatedButton(
                  onPressed: _loadPatientData,
                  child: const Text('Recargar'),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reportViewModel.reports.length,
          itemBuilder: (context, index) {
            final report = reportViewModel.reports[index];
            return _buildReportCard(report);
          },
        );
      },
    );
  }

  /// Builds the history tab
  Widget _buildHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildActivityTimeline()],
      ),
    );
  }

  /// Builds the patient card
  Widget _buildPatientCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    widget.patient.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.patient.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (widget.patient.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.patient.email!,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                ),
                _buildStatusChip(),
              ],
            ),
            if (widget.patient.phone != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(widget.patient.phone!),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the personal information card
  Widget _buildPersonalInfoCard() {
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
                  Icons.person,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Información Personal',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (widget.patient.age != null ||
                widget.patient.gender != null) ...[
              Row(
                children: [
                  if (widget.patient.age != null) ...[
                    Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${widget.patient.age} años'),
                    if (widget.patient.gender != null)
                      const SizedBox(width: 16),
                  ],
                  if (widget.patient.gender != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(widget.patient.gender!),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Agregado: ${_formatDate(widget.patient.addedDate)}'),
              ],
            ),
            if (widget.patient.lastConsultation != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Última consulta: ${_formatDate(widget.patient.lastConsultation!)}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds the professional notes card
  Widget _buildProfessionalNotesCard() {
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
                Icon(Icons.note, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Notas Profesionales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.patient.professionalNotes ?? 'No hay notas profesionales',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the medical history card
  Widget _buildMedicalHistoryCard() {
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
                  Icons.medical_services,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Historial Médico',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              widget.patient.medicalHistory ??
                  'No hay historial médico registrado',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (widget.patient.emergencyContact != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.emergency, size: 16, color: Colors.red[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Contacto de emergencia: ${widget.patient.emergencyContact}',
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a report card
  Widget _buildReportCard(PatientReportModel report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToReport(report),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.assessment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Reporte de Salud Mental',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getRiskColor(report.riskLevel).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getRiskColor(report.riskLevel).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      report.riskLevel.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _getRiskColor(report.riskLevel),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                report.executiveSummary,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.favorite, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Puntuación: ${report.wellnessScore}/100',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(report.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the activity timeline
  Widget _buildActivityTimeline() {
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
            _buildTimelineItem(
              icon: Icons.person_add,
              title: 'Paciente agregado',
              subtitle: 'Agregado a tu lista de pacientes',
              date: widget.patient.addedDate,
              color: Colors.blue,
            ),
            if (widget.patient.lastConsultation != null) ...[
              _buildTimelineItem(
                icon: Icons.event,
                title: 'Última consulta',
                subtitle: 'Consulta registrada',
                date: widget.patient.lastConsultation!,
                color: Colors.green,
              ),
            ],
            Consumer<PatientReportViewModel>(
              builder: (context, reportViewModel, child) {
                return _buildTimelineItem(
                  icon: Icons.assessment,
                  title: 'Reportes generados',
                  subtitle:
                      '${reportViewModel.reports.length} reportes disponibles',
                  date: DateTime.now(),
                  color: Colors.orange,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a timeline item
  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required DateTime date,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
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
                Text(
                  _formatDate(date),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the status chip
  Widget _buildStatusChip() {
    final viewModel = context.read<ProfessionalPatientViewModel>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: viewModel.getStatusColor(widget.patient.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: viewModel
              .getStatusColor(widget.patient.status)
              .withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            viewModel.getStatusIcon(widget.patient.status),
            size: 14,
            color: viewModel.getStatusColor(widget.patient.status),
          ),
          const SizedBox(width: 4),
          Text(
            widget.patient.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: viewModel.getStatusColor(widget.patient.status),
            ),
          ),
        ],
      ),
    );
  }

  /// Gets the color for risk level
  Color _getRiskColor(RiskLevel riskLevel) {
    switch (riskLevel) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  /// Navigates to report detail
  void _navigateToReport(PatientReportModel report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientReportScreen(report: report),
      ),
    );
  }

  /// Handles menu actions
  void _handleMenuAction(String action) {
    switch (action) {
      case 'edit':
        // TODO: Implement edit patient
        break;
      case 'status':
        // TODO: Implement change status
        break;
      case 'consultation':
        // TODO: Implement register consultation
        break;
      case 'remove':
        _confirmRemovePatient();
        break;
    }
  }

  /// Confirms patient removal
  Future<void> _confirmRemovePatient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Paciente'),
            content: Text(
              '¿Estás seguro de que deseas eliminar a ${widget.patient.name} de tu lista de pacientes?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmed == true && mounted) {
      final viewModel = context.read<ProfessionalPatientViewModel>();
      final success = await viewModel.removePatient(widget.patient.id);

      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
