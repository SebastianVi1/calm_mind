import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/view/profile_page.dart';
import 'package:re_mind/ui/view/stadistics_screen.dart';
import 'package:re_mind/ui/widgets/mood_lottie_container.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';
import 'package:re_mind/viewmodels/theme_view_model.dart';
import 'package:re_mind/viewmodels/tips_view_model.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        var theme = Theme.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Icon(Icons.home, color: Theme.of(context).brightness == Brightness.dark ? Colors.white: Colors.black,),
            toolbarHeight: 30,
            backgroundColor: Colors.transparent,
            actionsIconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark 
                ? Colors.white 
                : Colors.black,

            ),
            
            shadowColor: Colors.black,
            iconTheme: IconThemeData(
              color: Theme.of(context).brightness == Brightness.dark ? Colors.white: Colors.black,
            ),
            
            
          ),

          endDrawer: Drawer(
              width: 250,
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Lottie.asset('assets/animations/meditation.json',width: 200,)
                      )
                    ),
                    
                  ),
                  ListTile(
                    title: const Text('Perfil',textAlign: TextAlign.start,),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ProfilePage()),
                      );
                    },
  
                    leading: Icon(Icons.person),
                    
                  ),
                  ListTile(
                    title: const Text('Modo oscuro', textAlign: TextAlign.start,),
                    leading: Icon(Icons.dark_mode),
                    trailing: Consumer<ThemeViewModel>(
                      builder: (context, themeViewModel, child) {
                        return Switch(
                          value: themeViewModel.isDarkModeActive,
                          onChanged: (value) {
                            themeViewModel.toggleTheme();
                          },
                        );
                      },
                    ),
                  ),
                  ListTile(
                    title: const Text('Terminos y condiciones',textAlign: TextAlign.start,),
                    leading: Icon(Icons.file_copy_outlined),
                    
                  )
                ],
              ),
            ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  children: [
                    FadeInDown(
                      config: BaseAnimationConfig(
                        child: Text(
                          '¿Cómo te sientes ahora?',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold), 
                          textAlign: TextAlign.center,
                        ),
                      )
                    ),
                    const SizedBox(height: 10),
                    FadeInLeft(
                      config: BaseAnimationConfig(
                        delay: 800.ms,
                        useScrollForAnimation: true,
                        child: _buildMoodStates(viewModel, context),
                      )
                    ),
                    
                    const SizedBox(height: 20),
                    // Título y tendencia
                    
                    const SizedBox(height: 10),
                
                  ],
                ),
              ),
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
                          MaterialPageRoute(builder: (context) => const StadisticsScreen()),
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