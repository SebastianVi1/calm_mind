import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:calm_mind/ui/view/stadistics_screen.dart';
import 'package:calm_mind/ui/widgets/drawer_key.dart';
import 'package:calm_mind/ui/widgets/mood_lottie_container.dart';
import 'package:calm_mind/viewmodels/mood_view_model.dart';
import 'package:calm_mind/viewmodels/tips_view_model.dart';
import 'package:calm_mind/viewmodels/user_view_model.dart';
import 'dart:async';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) => _HomePageMain()
        );
      }
    );
  }
}

class _HomePageMain extends StatefulWidget {
  const _HomePageMain();

  @override
  State<_HomePageMain> createState() => _HomePageMainState();
}

class _HomePageMainState extends State<_HomePageMain> {
  int _timeRemaining = 10;
  Timer? _timer;
  Random rng = Random();
  int randomNumber = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose(){
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(){
    _timer = Timer.periodic(const Duration(seconds: 1), (timer){
      setState((){
        _timeRemaining--;
        if(_timeRemaining <=0) {
          _timer?.cancel();
          randomNumber = rng.nextInt(context.read<TipsViewModel>().tips.length);
          _timeRemaining = 10;
          _startTimer();
        }
      });
    });
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Consumer<MoodViewModel>(
      builder: (context, viewModel, child) {
        
        return Scaffold(
          appBar: AppBar(
            title: Icon(Icons.home, color: Theme.of(context).brightness == Brightness.dark ? Colors.white: Colors.black,),
            toolbarHeight: 30,
            actions: [
              
              IconButton(
                icon: Icon(Icons.menu),
                onPressed: () => openGlobalEndDrawer(context),
              ),
            ],
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
                        delay: 150.ms,
                        useScrollForAnimation: true,
                        child: _buildMoodStates(viewModel, context),
                      )
                    ),
                    
                    FadeInLeft(
                      config: BaseAnimationConfig(
                        
                        delay: 150.ms,
                        useScrollForAnimation: true,
                        child: _buildTipCard(randomNumber, _timeRemaining),
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
}
  Widget _buildMoodStates(MoodViewModel viewModel, BuildContext context) {
    var provider = Provider.of<MoodViewModel>(context);
    bool isLoading = provider.isLoading;   
    return Column(
      children: [
        // Mood selection row
        Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: viewModel.selectedMood?.color ?? Theme.of(context).primaryColor, width: 2),
            borderRadius: BorderRadius.circular(20),
            
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
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Tu estado de ánimo ha sido guardado'),
                                duration: Duration(seconds: 1),
                                backgroundColor: viewModel.selectedMood?.color ?? Colors.white,
                              ),
                            );
                            viewModel.saveMoodEntry();
                          }
                        : null,
                      
                      child: const Text('Guardar '),
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () async {
                       

                        try {
                          await context.read<MoodViewModel>().fetchMoodHistory(context.read<UserViewModel>().currentUser.uid);
                         
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StadisticsScreen()),
                          );
                        } catch (e) {
                          Navigator.pop(context); // Cerrar el indicador de carga
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error al cargar el historial: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      },
                      child: isLoading ? Lottie.asset('assets/animations/loading.json', width: 24, height: 20) : const Text('Historial'),
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

  Widget _buildTipCard(int randomNumber, int timeRemaining) {
    return Consumer<TipsViewModel>(
      builder: (context, viewModel, child) {
        var moodList = viewModel.tips;
        var tip = moodList[randomNumber];
        var theme = Theme.of(context);
        
        return SizedBox(
          
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 1500),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeInOut,
                    reverseCurve: Curves.easeInOut,
                  ),
                  child: child,
                );
              },
              child: Container(
                key: ValueKey<int>(randomNumber),
                padding: EdgeInsets.all(15),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).brightness == Brightness.dark ? Color(0xFF0D47A1).withValues(alpha: 0.6) : Color(0xFFF0F4FF), // Lavender,
                  
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(1, 5),
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 5,
                    )
                  ]
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        shadows: [Shadow(color: Colors.black.withValues(alpha: 0.2), offset: Offset(1, 1))]
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      tip.content,
                      style: theme.textTheme.labelLarge,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    );
  }
