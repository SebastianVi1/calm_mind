import 'package:flutter/material.dart';
import 'package:flutter_animate_on_scroll/flutter_animate_on_scroll.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/viewmodels/mood_view_model.dart';

class EmotionsScreen extends StatefulWidget {
  const EmotionsScreen({super.key});

  @override
  State<EmotionsScreen> createState() => _EmotionsScreenState();
}

class _EmotionsScreenState extends State<EmotionsScreen> {
  
  Set<String> _selectedOption = {'todos'};  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildMoodCard(context, context.watch<MoodViewModel>())
          ],
        ),
      ),
    );
  }Widget _buildMoodCard(BuildContext context, MoodViewModel viewModel) {
    // Ya no se define _selectedOption aquí, se usa la variable de la clase
    if (viewModel.moodHistory.isEmpty) {
      return Expanded(
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            
            child: Lottie.asset('assets/animations/meditation.json',width: 150,)
          ),
        ),
      );
    }

    return Expanded(
      child: Column(
        children: [
          Align(
            heightFactor: 0.7,
            alignment: Alignment.topLeft,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(Icons.arrow_back),
            ),
          ),
          Text(
            'Todas las notas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8),
              
            ),
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment<String>(
                  value: 'hoy',
                  label: Text('Hoy'),
                  icon: Icon(Icons.today),
                ),
                ButtonSegment<String>(
                  value: 'semanal',
                  label: Text('Semanal'),
                  icon: Icon(Icons.calendar_view_week),
                ),
                ButtonSegment<String>(
                  value: 'todos',
                  label: Text('Todos'),
                  icon: Icon(Icons.calendar_month),
                ),
              ],
              selected: _selectedOption,              
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedOption = newSelection;
                  
                });
              },
              style: ButtonStyle(
                
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).primaryColor.withAlpha(50);
                    }
                    return null;
                  },
                ),
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).colorScheme.primary;
                    }
                    return Theme.of(context).textTheme.bodyLarge?.color;
                  },
                ),
                side: WidgetStateProperty.resolveWith<BorderSide?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      );
                    }
                    return BorderSide(
                      color: Theme.of(context).dividerColor,
                      width: 1,
                    );
                  },
                ),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: viewModel.filterMoods(_selectedOption.first).length,
              itemBuilder: (context, index) {
                final actualMood = viewModel.filterMoods(_selectedOption.first)[index];
                final date = actualMood.timestamp;
                final dateString = '${date.day}/${date.month}/${date.year} - ${date.hour}:${date.minute}';
                
                return FadeInRight(

                  config: BaseAnimationConfig(
                      useScrollForAnimation: true,
                      delay: 300.ms,
                      curves: Curves.easeInOut,
                      child: GestureDetector(
                        onLongPress: () {
                          
                        },
                        child: FadeInDown(
                          config: BaseAnimationConfig(
                            child: Card(
                              margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                              child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  leading: Lottie.asset(
                                    actualMood.lottieAsset,
                                    animate: false,
                                    frameRate: FrameRate.max,
                                  ),
                                  title: Text(
                                    actualMood.label,
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                      color: actualMood.color,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5
                                    ),
                                  ),
                                  subtitle: Text(
                                    dateString,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.grey),
                                  ),
                                ),
                                if (actualMood.note != null && actualMood.note!.trim().isNotEmpty) 
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16.0),
                                    child: Container(
                                      padding: const EdgeInsets.all(10),
                                      
                                      decoration: BoxDecoration(
                                        color: Colors.grey[400],
                                        borderRadius: BorderRadius.circular(20)
                                      ),
                                      
                                      child: Text(
                                        actualMood.note!,
                                        style: Theme.of(context).textTheme.labelMedium,
                                        textAlign: TextAlign.start
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ),
                        ),
                      ),
                    )
                  )
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}