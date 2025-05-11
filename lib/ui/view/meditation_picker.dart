import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/models/meditation_audio_model.dart';
import 'package:re_mind/ui/view/meditation_scree.dart';
import 'package:re_mind/viewmodels/meditation_view_model.dart';

class MeditationPicker extends StatelessWidget {
  const MeditationPicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 30,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            Text(
              'Selecciona la meditacion que deseasescuchar',
              style: Theme.of(context).textTheme.titleLarge,
              softWrap: true,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10,),
            Consumer<MeditationViewModel>(
              
              builder: (context, viewModel, child) {
                
                return Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.urls.length,
                    itemBuilder: (context, index) {
                      var meditation = viewModel.urls[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Card(
                          
                          elevation: 5,
                          child: FadeInRight(
                            config: BaseAnimationConfig(
                            child: ListTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              onTap: (){_navigateToMeditation(context, meditation);},
                              title: Text(
                                viewModel.urls[index].title,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                              subtitle: Text(
                                viewModel.urls[index].duration,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey, fontWeight: FontWeight.bold),
                                
                                ),
                              
                            ),
                          ),
                        )
                        ),
                      );
                    },
                  ),
                );
              },
              
            ),
          ],
        ),
      ),
    );
  }

   void _navigateToMeditation(BuildContext context, MeditationAudioModel meditation) {
    // Set the selected meditation in the ViewModel
    final viewModel = Provider.of<MeditationViewModel>(context, listen: false);
    viewModel.setSelectedMeditation(meditation);
    
    // Navigate to meditation screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MeditationScreen()),
    );
  }
}