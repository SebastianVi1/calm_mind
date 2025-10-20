import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../viewmodels/appointment_view_model.dart';
import 'add_appointment_screen.dart';
import 'package:intl/intl.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppointmentViewModel()..loadAppointments(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Consultas'), centerTitle: true),
        body: Consumer<AppointmentViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (viewModel.appointments.isEmpty) {
              return Center(
                child: Text(
                  'No hay consultas programadas',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              );
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
                        Text(
                          DateFormat(
                            'dd/MM/yyyy HH:mm',
                          ).format(appointment.dateTime),
                        ),
                        Text(appointment.patientPhone),
                      ],
                    ),
                    trailing: Icon(
                      Icons.circle,
                      color: appointment.isDone ? Colors.green : Colors.orange,
                      size: 12,
                    ),
                  ),
                );
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddAppointmentScreen(),
              ),
            );
          },
          icon: const Icon(Icons.add),
          label: const Text('Nueva Consulta'),
        ),
      ),
    );
  }
}
