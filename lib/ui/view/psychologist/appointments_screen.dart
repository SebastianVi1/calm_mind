import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/appointment_view_model.dart';
import 'add_appointment_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  void initState() {
    super.initState();
    // Load appointments when screen opens
    Future.microtask(
      () => context.read<AppointmentViewModel>().loadAppointments(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas'), centerTitle: true),
      body: Consumer<AppointmentViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(viewModel.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.loadAppointments(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.appointments.isEmpty) {
            return const Center(child: Text('No hay consultas programadas'));
          }

          return ListView.builder(
            itemCount: viewModel.appointments.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final appointment = viewModel.appointments[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      appointment.patientName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(appointment.patientName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ID: ${appointment.patientId}'),
                      Text(
                        DateFormat(
                          'MMM d, y - HH:mm',
                        ).format(appointment.dateTime),
                      ),
                      Text(appointment.patientPhone),
                      const SizedBox(height: 6),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          visualDensity: VisualDensity.compact,
                          avatar: Icon(
                            appointment.isDone
                                ? Icons.check_circle
                                : Icons.schedule,
                            size: 16,
                            color:
                                appointment.isDone
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                          label: Text(
                            appointment.isDone ? 'Completada' : 'Pendiente',
                            style: TextStyle(
                              color:
                                  appointment.isDone
                                      ? Colors.green[900]
                                      : Colors.orange[900],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          backgroundColor:
                              appointment.isDone
                                  ? Colors.green[50]
                                  : Colors.orange[50],
                          side: BorderSide(
                            color:
                                appointment.isDone
                                    ? Colors.green
                                    : Colors.orange,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            child: ListTile(
                              leading: Icon(
                                appointment.isDone
                                    ? Icons.refresh
                                    : Icons.check,
                                color:
                                    appointment.isDone
                                        ? Colors.orange
                                        : Colors.green,
                              ),
                              title: Text(
                                appointment.isDone
                                    ? 'Marcar Pendiente'
                                    : 'Marcar Completada',
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap:
                                () => viewModel.toggleAppointmentStatus(
                                  appointment.id,
                                ),
                          ),
                          PopupMenuItem(
                            child: const ListTile(
                              leading: Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              title: Text(
                                'Eliminar',
                                style: TextStyle(color: Colors.red),
                              ),
                              contentPadding: EdgeInsets.zero,
                            ),
                            onTap:
                                () => _confirmDelete(context, appointment.id),
                          ),
                        ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddAppointmentScreen(),
            ),
          );
          if (result == true && mounted) {
            context.read<AppointmentViewModel>().loadAppointments();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva Consulta'),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String appointmentId,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar Consulta'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar esta consulta?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );

    if (confirm == true && mounted) {
      await context.read<AppointmentViewModel>().deleteAppointment(
        appointmentId,
      );
    }
  }
}
