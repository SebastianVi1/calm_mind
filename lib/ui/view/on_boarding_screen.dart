import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/question_view_model.dart';
import '../widgets/question_widget.dart';

/// Screen that displays onboarding questions using MVVM pattern
/// Uses ChangeNotifier for state management and Stack for layout
class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuestionViewModel(),
      child: Consumer<QuestionViewModel>(
        builder: (context, viewModel, child) {
          return Scaffold(
            body: Stack(
              children: [
                // Main question widget with background
                WQuestionWidget(
                  question: viewModel.currentQuestion,
                  selectedAnswer: viewModel.currentAnswer,
                  onAnswerChanged: viewModel.selectAnswer,
                ),
                // Back button for first question
                if (viewModel.isFirstQuestion)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
