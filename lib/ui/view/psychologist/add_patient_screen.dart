import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/professional_patient_view_model.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _professionalNotesController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  String? _selectedGender;
  bool _isAdding = false;
  int _currentStep = 0;

  @override
  void dispose() {
    _userIdController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _emergencyContactController.dispose();
    _professionalNotesController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_userIdController.text.trim().isEmpty || _nameController.text.trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor completa los campos requeridos'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return false;
        }
        return true;
      case 1:
        return true;
      case 2:
        return true;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Paciente'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Stepper(
            currentStep: _currentStep,
            onStepContinue: () {
              if (!_validateCurrentStep()) return;
              if (_currentStep < 2) {
                setState(() => _currentStep++);
              } else {
                _addPatient();
              }
            },
            onStepCancel: () {
              if (_currentStep > 0) {
                setState(() => _currentStep--);
              } else {
                Navigator.pop(context);
              }
            },
            onStepTapped: (step) {
              if (step < _currentStep) {
                setState(() => _currentStep = step);
              }
            },
            controlsBuilder: (context, details) {
              return Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    FilledButton(
                      onPressed: _isAdding ? null : details.onStepContinue,
                      child: Text(_currentStep == 2 ? 'Agregar Paciente' : 'Continuar'),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: Text(_currentStep == 0 ? 'Cancelar' : 'Atrás'),
                    ),
                  ],
                ),
              );
            },
            steps: [
              Step(
                title: const Text('Información Básica'),
                subtitle: const Text('ID y nombre del paciente'),
                isActive: _currentStep >= 0,
                state: _currentStep > 0 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _userIdController,
                      decoration: const InputDecoration(
                        labelText: 'ID del Usuario *',
                        hintText: 'Ingresa el ID del usuario',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre Completo *',
                        hintText: 'Nombre del paciente',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Información Personal'),
                subtitle: const Text('Edad, género y contacto'),
                isActive: _currentStep >= 1,
                state: _currentStep > 1 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _ageController,
                      decoration: const InputDecoration(
                        labelText: 'Edad',
                        hintText: 'Ej: 25',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.cake),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedGender,
                      decoration: const InputDecoration(
                        labelText: 'Género',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
                        DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
                        DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                      ],
                      onChanged: (value) => setState(() => _selectedGender = value),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emergencyContactController,
                      decoration: const InputDecoration(
                        labelText: 'Contacto de Emergencia',
                        hintText: 'Nombre y teléfono del contacto',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.emergency),
                      ),
                    ),
                  ],
                ),
              ),
              Step(
                title: const Text('Notas e Historial'),
                subtitle: const Text('Notas profesionales y datos médicos'),
                isActive: _currentStep >= 2,
                state: _currentStep > 2 ? StepState.complete : StepState.indexed,
                content: Column(
                  children: [
                    TextFormField(
                      controller: _professionalNotesController,
                      decoration: const InputDecoration(
                        labelText: 'Notas Profesionales',
                        hintText: 'Observaciones iniciales sobre el paciente...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit_note),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _medicalHistoryController,
                      decoration: const InputDecoration(
                        labelText: 'Historial Médico',
                        hintText: 'Condiciones médicas, medicamentos, alergias...',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.medical_information),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 18, color: theme.colorScheme.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Revisa los datos antes de confirmar. Podrás editarlos después.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPatient() async {
    setState(() => _isAdding = true);

    try {
      final viewModel = context.read<ProfessionalPatientViewModel>();

      final success = await viewModel.addPatientByUserId(
        userId: _userIdController.text.trim(),
        name: _nameController.text.trim(),
        professionalNotes: _professionalNotesController.text.trim().isEmpty ? null : _professionalNotesController.text.trim(),
        age: _ageController.text.trim().isEmpty ? null : int.tryParse(_ageController.text.trim()),
        gender: _selectedGender,
        emergencyContact: _emergencyContactController.text.trim().isEmpty ? null : _emergencyContactController.text.trim(),
        medicalHistory: _medicalHistoryController.text.trim().isEmpty ? null : _medicalHistoryController.text.trim(),
      );

      if (success && mounted) {
        await viewModel.loadPatientReports(_userIdController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Paciente agregado exitosamente'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(viewModel.errorMessage ?? 'Error al agregar paciente'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }
}
