import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/build_background.dart';
import '../../viewmodels/question_view_model.dart';
import '../widgets/question_widget.dart';

/// Screen that displays onboarding questions using MVVM pattern
/// Uses ChangeNotifier for state management and Stack for layout
class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create and provide the ViewModel to the widget tree
    return ChangeNotifierProvider(
      create: (_) => QuestionViewModel(),
      child: Consumer<QuestionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                BuildBackground.backgroundWelcomeScreen(),
                // Main question widget with background
                WQuestionWidget(
                  question: viewModel.currentQuestion,
                  selectedAnswer: viewModel.currentAnswer,
                  onAnswerChanged: viewModel.selectAnswer,
                ),
                const SizedBox(height: 20,),
                if (viewModel.isFirstQuestion)
                  Positioned(
                    top: 20,
                    
                    child: ClipRRect(
                      child: IconButton(
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context), 
                        icon: Icon(Icons.arrow_back_rounded)),
                    ),
                  ),
                // Navigation buttons positioned at the bottom
                
              ],
            ),
          );
        },
      ),
    );
  }
}