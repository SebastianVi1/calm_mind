import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/mood_model.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';

class MoodHistoryPage extends StatelessWidget {
  const MoodHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Historial de Ánimo'),
      ),
      body: Consumer<MoodViewModel>(
        builder: (context, viewModel, child) {
          final moodHistory = viewModel.getAllMoodHistory();
          
          if (moodHistory.isEmpty) {
            return const Center(
              child: Text('Aún no has registrado ningún estado de ánimo'),
            );
          }
          
          return ListView.builder(
            itemCount: moodHistory.length,
            itemBuilder: (context, index) {
              final mood = moodHistory[index];
              return _buildMoodHistoryItem(context, mood);
            },
          );
        },
      ),
    );
  }
  
  Widget _buildMoodHistoryItem(BuildContext context, MoodModel mood) {
    final date = mood.timestamp;
    final dateString = date != null 
        ? '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute.toString().padLeft(2, '0')}'
        : 'Fecha desconocida';
        
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: mood.color.withOpacity(0.2),
                  child: Text(
                    mood.label[0], // Primera letra del nombre
                    style: TextStyle(
                      color: mood.color, 
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      dateString,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (mood.note != null && mood.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mood.note!,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 