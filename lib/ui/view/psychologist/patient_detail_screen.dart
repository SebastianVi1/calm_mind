import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/professional_patient_view_model.dart';
import '../../../viewmodels/patient_report_view_model.dart';
import '../../../models/professional_patient_model.dart';
import '../../../models/patient_report_model.dart';
import '../../view/patient_report_screen.dart';
import 'add_appointment_screen.dart';

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
  late ProfessionalPatientModel _patient;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _patient = widget.patient;

    // Cargar reportes al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPatientData();
    });
  }

  Future<void> _loadPatientData() async {
    try {
      print('Loading patient data for: ${_patient.userId}');
      final reportViewModel = Provider.of<PatientReportViewModel>(
        context,
        listen: false,
      );
      await reportViewModel.loadUserReportsByUserId(_patient.userId);
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

  /// Loads patient reports (kept via _loadPatientData)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_patient.name),
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
                    _patient.name[0].toUpperCase(),
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
                        _patient.name,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (_patient.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _patient.email!,
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
            if (_patient.phone != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(_patient.phone!),
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
            if (_patient.age != null || _patient.gender != null) ...[
              Row(
                children: [
                  if (_patient.age != null) ...[
                    Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${_patient.age} años'),
                    if (_patient.gender != null) const SizedBox(width: 16),
                  ],
                  if (_patient.gender != null) ...[
                    Icon(Icons.person, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(_patient.gender!),
                  ],
                ],
              ),
              const SizedBox(height: 8),
            ],
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Agregado: ${_formatDate(_patient.addedDate)}'),
              ],
            ),
            if (_patient.lastConsultation != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Última consulta: ${_formatDate(_patient.lastConsultation!)}',
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
              _patient.professionalNotes ?? 'No hay notas profesionales',
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
              _patient.medicalHistory ?? 'No hay historial médico registrado',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_patient.emergencyContact != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.emergency, size: 16, color: Colors.red[600]),
                  const SizedBox(width: 4),
                  Text('Contacto de emergencia: ${_patient.emergencyContact}'),
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
              date: _patient.addedDate,
              color: Colors.blue,
            ),
            if (_patient.lastConsultation != null) ...[
              _buildTimelineItem(
                icon: Icons.event,
                title: 'Última consulta',
                subtitle: 'Consulta registrada',
                date: _patient.lastConsultation!,
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
        color: viewModel.getStatusColor(_patient.status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: viewModel.getStatusColor(_patient.status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            viewModel.getStatusIcon(_patient.status),
            size: 14,
            color: viewModel.getStatusColor(_patient.status),
          ),
          const SizedBox(width: 4),
          Text(
            _patient.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: viewModel.getStatusColor(_patient.status),
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
        _openEditPatientDialog();
        break;
      case 'status':
        _openChangeStatusSheet();
        break;
      case 'consultation':
        _registerConsultation();
        break;
      case 'remove':
        _confirmRemovePatient();
        break;
    }
  }

  Future<void> _registerConsultation() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAppointmentScreen(initialPatient: _patient),
      ),
    );

    if (result == true && mounted) {
      // Update last consultation to now (assumption: consultation scheduled now)
      final vm = context.read<ProfessionalPatientViewModel>();
      await vm.updateLastConsultation(_patient.id, DateTime.now());
      setState(() {
        _patient = _patient.copyWith(lastConsultation: DateTime.now());
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Consulta registrada exitosamente')),
      );
    }
  }

  void _openChangeStatusSheet() {
    final vm = context.read<ProfessionalPatientViewModel>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              ListTile(
                title: const Text('Cambiar estado del paciente'),
                subtitle: Text('Actual: ${_patient.status.displayName}'),
              ),
              const Divider(height: 1),
              ...PatientStatus.values.map((status) {
                final color = vm.getStatusColor(status);
                final icon = vm.getStatusIcon(status);
                final selected = status == _patient.status;
                return ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(status.displayName),
                  trailing: selected ? Icon(Icons.check, color: color) : null,
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (status == _patient.status) return;
                    final updated = _patient.copyWith(status: status);
                    final ok = await vm.updatePatient(updated);
                    if (ok && mounted) {
                      setState(() => _patient = updated);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Estado actualizado a ${status.displayName}',
                          ),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _openEditPatientDialog() {
    final nameCtrl = TextEditingController(text: _patient.name);
    final emailCtrl = TextEditingController(text: _patient.email ?? '');
    final phoneCtrl = TextEditingController(text: _patient.phone ?? '');
    final notesCtrl = TextEditingController(
      text: _patient.professionalNotes ?? '',
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Editar información'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notas profesionales',
                    prefixIcon: Icon(Icons.note),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updated = _patient.copyWith(
                  name:
                      nameCtrl.text.trim().isEmpty
                          ? _patient.name
                          : nameCtrl.text.trim(),
                  email:
                      emailCtrl.text.trim().isEmpty
                          ? null
                          : emailCtrl.text.trim(),
                  phone:
                      phoneCtrl.text.trim().isEmpty
                          ? null
                          : phoneCtrl.text.trim(),
                  professionalNotes:
                      notesCtrl.text.trim().isEmpty
                          ? null
                          : notesCtrl.text.trim(),
                );
                final ok = await context
                    .read<ProfessionalPatientViewModel>()
                    .updatePatient(updated);
                if (!mounted) return;
                if (ok) {
                  setState(() => _patient = updated);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Paciente actualizado'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text('Guardar cambios'),
            ),
          ],
        );
      },
    );
  }

  /// Confirms patient removal
  Future<void> _confirmRemovePatient() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Paciente'),
            content: Text(
              '¿Estás seguro de que deseas eliminar a ${_patient.name} de tu lista de pacientes?',
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
      final success = await viewModel.removePatient(_patient.id);

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
