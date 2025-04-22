import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/mood_lottie_button.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';
import 'package:re_mind/ui/view/mood_history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Text(
                  '¿Cómo te sientes ahora?',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), 
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                _buildMoodStates(viewModel, context),
                const SizedBox(height: 20),
                
                  
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMoodStates(MoodViewModel viewModel, BuildContext context) {
    return Column(
      children: [
        // Mood selection row
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: viewModel.selectedMood?.color ?? Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: viewModel.availableMoods.map((mood) {
                  return WMoodLottieContainer(
                    mood: mood,
                    isSelected: viewModel.selectedMood == mood,
                    onTap: () {
                      viewModel.selectMood(mood);
                    },
                  );
                }).toList(),
              ),
              
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  enabled: viewModel.selectedMood != null,
                  controller: viewModel.noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: viewModel.selectedMood != null 
                      ? 'Agrega una nota de cómo te sientes (opcional)'
                      : 'Selecciona un estado de ánimo primero',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                  ),
                ),
              ),
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  
                  Flexible(
                    child: ElevatedButton(
                      onPressed: viewModel.selectedMood != null
                        ? () {
                            viewModel.saveMoodEntry();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Tu estado de ánimo ha sido guardado'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                      
                      child: const Text('Guardar '),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const MoodHistoryPage()),
                        );
                      },
                      child: const Text('Historial'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
          
        ),

      ],
    );
  }

  Widget _buildMoodAdvice() {
    return Consumer<TipsViewModel>(
      builder: (context, viewModel, child) {
        return Container();
        //TODO: add a card with an advice depending on the mood selected
      }
    );
  }
} 