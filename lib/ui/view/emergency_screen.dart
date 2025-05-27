import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/viewmodels/emergency_view_model.dart';
import 'package:calm_mind/models/emergency_contact.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Contactos de Emergencia'),
      ),
      body: Consumer<EmergencyViewModel>(
        builder: (context, viewModel, child) {
          return ListView.builder(
            itemCount: viewModel.allContacts.length,
            itemBuilder: (context, index) {
              final contact = viewModel.allContacts[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                child: ListTile(
                  leading: Icon(
                    contact.isPersonal ? Icons.person : Icons.emergency,
                    color: contact.isPersonal ? Colors.blue : Colors.red,
                  ),
                  title: Text(contact.name),
                  subtitle: Text(contact.phoneNumber),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.phone),
                        onPressed: () => _makePhoneCall(contact.phoneNumber),
                      ),
                      if (contact.isPersonal)
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => viewModel.removePersonalContact(contact.id),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAddContactDialog(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final relationshipController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        
        title: const Text('Agregar Contacto de Emergencia'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 8,),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 8,),
            TextField(
              controller: relationshipController,
              decoration: const InputDecoration(labelText: 'Relación (opcional)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              final contact = EmergencyContact(
                id: DateTime.now().toString(),
                name: nameController.text,
                phoneNumber: phoneController.text,
                relationship: relationshipController.text,
                isPersonal: true,
              );
              context.read<EmergencyViewModel>().addPersonalContact(contact);
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }
} 