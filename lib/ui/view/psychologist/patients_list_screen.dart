import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/professional_patient_view_model.dart';
import '../../../models/professional_patient_model.dart';
import 'add_patient_screen.dart';
import 'patient_detail_screen.dart';

/// Screen that shows the list of professional patients
/// Allows viewing, searching, and managing patients
class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load patients when screen opens
    Future.microtask(
      () => context.read<ProfessionalPatientViewModel>().loadPatients(),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Formats a DateTime to a readable string
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Pacientes'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ProfessionalPatientViewModel>().refresh();
            },
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      body: Consumer<ProfessionalPatientViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading && viewModel.patients.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null && viewModel.patients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar pacientes',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    viewModel.errorMessage!,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadPatients(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.patients.isEmpty) {
            return _buildEmptyState(context);
          }

          return Column(
            children: [
              _buildSearchBar(context, viewModel),
              _buildPatientsList(context, viewModel),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPatientScreen()),
          );
          if (result == true && mounted) {
            context.read<ProfessionalPatientViewModel>().refresh();
          }
        },
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar Paciente'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }

  /// Builds the search bar
  Widget _buildSearchBar(
    BuildContext context,
    ProfessionalPatientViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar pacientes...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      viewModel.clearSearch();
                    },
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Theme.of(context).colorScheme.surfaceVariant,
        ),
        onChanged: (value) {
          viewModel.updateSearchQuery(value);
        },
      ),
    );
  }

  /// Builds the patients list
  Widget _buildPatientsList(
    BuildContext context,
    ProfessionalPatientViewModel viewModel,
  ) {
    final patients = viewModel.filteredPatients;

    if (patients.isEmpty && viewModel.searchQuery.isNotEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No se encontraron pacientes',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: patients.length,
        itemBuilder: (context, index) {
          final patient = patients[index];
          return _buildPatientCard(context, patient, viewModel);
        },
      ),
    );
  }

  /// Builds a patient card
  Widget _buildPatientCard(
    BuildContext context,
    ProfessionalPatientModel patient,
    ProfessionalPatientViewModel viewModel,
  ) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToPatientDetail(context, patient),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      patient.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          patient.name,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        if (patient.email != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            patient.email!,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.grey[600]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusChip(patient.status, viewModel),
                ],
              ),
              if (patient.age != null || patient.gender != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (patient.age != null) ...[
                      Icon(Icons.cake, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${patient.age} años',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                    if (patient.age != null && patient.gender != null) ...[
                      const SizedBox(width: 16),
                    ],
                    if (patient.gender != null) ...[
                      Icon(Icons.person, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        patient.gender!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
              if (patient.professionalNotes != null &&
                  patient.professionalNotes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  patient.professionalNotes!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(width: 4),
                  Text(
                    'Agregado: ${_formatDate(patient.addedDate)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                  if (patient.lastConsultation != null) ...[
                    const SizedBox(width: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Última consulta: ${_formatDate(patient.lastConsultation!)}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status chip
  Widget _buildStatusChip(
    PatientStatus status,
    ProfessionalPatientViewModel viewModel,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: viewModel.getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: viewModel.getStatusColor(status).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            viewModel.getStatusIcon(status),
            size: 14,
            color: viewModel.getStatusColor(status),
          ),
          const SizedBox(width: 4),
          Text(
            status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: viewModel.getStatusColor(status),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No tienes pacientes',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Agrega pacientes para comenzar a gestionar su atención',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddPatientScreen(),
                ),
              );
              if (result == true && mounted) {
                context.read<ProfessionalPatientViewModel>().refresh();
              }
            },
            icon: const Icon(Icons.person_add),
            label: const Text('Agregar Primer Paciente'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Navigates to patient detail screen
  void _navigateToPatientDetail(
    BuildContext context,
    ProfessionalPatientModel patient,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PatientDetailScreen(patient: patient),
      ),
    );
  }
}
