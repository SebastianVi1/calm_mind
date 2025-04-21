import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/mood_lottie_button.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';

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
                  'Como te sientes el dia de hoy?',
                  style: Theme.of(context).textTheme.bodyMedium, 
                  textAlign: TextAlign.center, 
                ),
                const SizedBox(height: 40,),
                _buildMoodStates(viewModel, context),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMoodStates(MoodViewModel viewModel, BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
        borderRadius: BorderRadius.circular(20)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: viewModel.availableMoods.map((mood) {
          return WMoodLottieButton(
            mood: mood,
            isSelected: viewModel.selectedMood == mood,
            onTap: () {
              viewModel.updateMood(mood);
            },
          );
        }).toList(),
      ),
    );
  }
} 