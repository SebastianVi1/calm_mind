import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/appointment.dart';
import '../../../models/professional_patient_model.dart';
import '../../../viewmodels/appointment_view_model.dart';
import '../../../viewmodels/professional_patient_view_model.dart';

class AddAppointmentScreen extends StatefulWidget {
  final ProfessionalPatientModel? initialPatient;

  const AddAppointmentScreen({super.key, this.initialPatient});

  @override
  State<AddAppointmentScreen> createState() => _AddAppointmentScreenState();
}

class _AddAppointmentScreenState extends State<AddAppointmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _patientIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  ProfessionalPatientModel? _selectedPatient;

  @override
  void initState() {
    super.initState();
    // Prefill when an initial patient is provided
    if (widget.initialPatient != null) {
      _applySelectedPatient(widget.initialPatient!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Consulta'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Paciente',
                  icon: Icon(Icons.person),
                ),
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              // Patient selector and current selection
              _buildPatientSelector(context),
              const SizedBox(height: 12),
              if (_selectedPatient != null) ...[
                _buildPatientHero(_selectedPatient!),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                  icon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator:
                    (value) =>
                        value?.isEmpty ?? true ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Icon(Icons.calendar_today),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        'Fecha: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.access_time),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _selectTime(context),
                      child: Text(
                        'Hora: ${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notas',
                  icon: Icon(Icons.note),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAppointment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Guardar Consulta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Widget _buildPatientSelector(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.person_search),
            label: Text(
              _selectedPatient == null
                  ? 'Seleccionar paciente registrado'
                  : 'Cambiar paciente',
            ),
            onPressed: _openPatientPicker,
          ),
        ),
        if (_selectedPatient != null) ...[
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Quitar selección',
            icon: const Icon(Icons.clear),
            onPressed: () {
              setState(() {
                _selectedPatient = null;
                _patientIdController.clear();
                // Mantener nombre/teléfono escritos manualmente
              });
            },
          ),
        ],
      ],
    );
  }

  Future<void> _openPatientPicker() async {
    final vm = context.read<ProfessionalPatientViewModel>();
    if (!vm.isLoading && vm.patients.isEmpty) {
      await vm.loadPatients();
    }

    if (!mounted) return;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(ctx).size.height * 0.7,
            child: Consumer<ProfessionalPatientViewModel>(
              builder: (context, viewModel, _) {
                if (viewModel.isLoading && viewModel.patients.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (viewModel.patients.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No hay pacientes registrados aún.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: viewModel.patients.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final p = viewModel.patients[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(p.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (p.email != null && p.email!.isNotEmpty)
                            Text(p.email!),
                          if (p.phone != null && p.phone!.isNotEmpty)
                            Text(p.phone!),
                        ],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        _applySelectedPatient(p);
                      },
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _applySelectedPatient(ProfessionalPatientModel p) {
    setState(() {
      _selectedPatient = p;
      _patientIdController.text = p.id;
      _nameController.text = p.name;
      if (p.phone != null) _phoneController.text = p.phone!;
    });
  }

  Widget _buildPatientHero(ProfessionalPatientModel patient) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Hero(
              tag: 'patient-${patient.id}',
              child: CircleAvatar(
                radius: 28,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  patient.name.isNotEmpty ? patient.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (patient.phone != null && patient.phone!.isNotEmpty)
                    Text(
                      patient.phone!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  if (patient.email != null && patient.email!.isNotEmpty)
                    Text(
                      patient.email!,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveAppointment() async {
    if (!_formKey.currentState!.validate()) return;

    final appointment = Appointment(
      patientId: _patientIdController.text,
      patientName: _nameController.text,
      patientPhone: _phoneController.text,
      dateTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      notes: _notesController.text,
    );

    await context.read<AppointmentViewModel>().addAppointment(appointment);
    if (mounted) Navigator.pop(context, true);
  }

  @override
  void dispose() {
    _patientIdController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
