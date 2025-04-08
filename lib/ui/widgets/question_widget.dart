import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:re_mind/models/question_model.dart';
import 'package:re_mind/ui/constants/app_constants.dart';
import 'package:re_mind/ui/widgets/build_background.dart';
import 'package:re_mind/viewmodels/question_view_model.dart';
import 'package:provider/provider.dart';

/// Widget that displays a question with multiple choice options.
/// It handles the selection of answers and navigation between questions.
class WQuestionWidget extends StatefulWidget {
  /// The question model containing the question text, description and options
  final QuestionModel question;
  
  /// The currently selected answer for this question
  final String selectedAnswer;
  
  /// Callback function called when an answer is selected
  final Function(String) onAnswerChanged;

  const WQuestionWidget({
    super.key,
    required this.question,
    required this.selectedAnswer,
    required this.onAnswerChanged,
  });

  @override
  State<WQuestionWidget> createState() => _WQuestionWidgetState();
}

class _WQuestionWidgetState extends State<WQuestionWidget> {
  @override
  Widget build(BuildContext context) {
    final deviceHeight = MediaQuery.sizeOf(context).height;
    final viewModel = Provider.of<QuestionViewModel>(context);
    
    return Stack(
      fit: StackFit.expand,
      children: [
        BuildBackground.backgroundWelcomeScreen(),
        _buildContent(deviceHeight),
        _buildNavigationButtons(viewModel),
      ],
    );
  }

  /// Builds the main content container with proper padding and safe area
  Widget _buildContent(double deviceHeight) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppConstants.contentHorizontalPadding),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: AppConstants.topSpacing),
            _buildQuestionText(),
            SizedBox(height: AppConstants.topSpacing),
            _buildDescriptionText(),
            SizedBox(height: deviceHeight * AppConstants.optionsSpacing),
            _buildOptions(),
          ],
        ),
      ),
    );
  }

  /// Builds the question text with proper styling
  Widget _buildQuestionText() {
    return Text(
      widget.question.question,
      style: Theme.of(context).textTheme.titleLarge,
      textAlign: TextAlign.center,
    );
  }

  /// Builds the animated description text using AnimatedTextKit
  Widget _buildDescriptionText() {
    return AnimatedTextKit(
      isRepeatingAnimation: false,
      animatedTexts: [
        TypewriterAnimatedText(
          widget.question.description,
          speed: AppConstants.textAnimationDuration,
          textAlign: TextAlign.center,
          textStyle: Theme.of(context).textTheme.bodyLarge,
        )
      ],
    );
  }

  /// Builds the list of option buttons
  Widget _buildOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.question.options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value;
        final isSelected = widget.selectedAnswer == option;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: AppConstants.optionButtonVerticalMargin),
          child: Semantics(
            label: 'Opción ${index + 1}: $option',
            selected: isSelected,
            button: true,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: AppConstants.optionButtonVerticalPadding),
                  backgroundColor: isSelected 
                      ? AppConstants.selectedOptionColor 
                      : AppConstants.unselectedOptionColor,
                  textStyle: Theme.of(context).textTheme.labelLarge,
                  elevation: 7,
                  minimumSize: Size(double.infinity, AppConstants.optionButtonHeight),
                ),
                onPressed: () => widget.onAnswerChanged(option),
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the navigation buttons positioned at the bottom
  Widget _buildNavigationButtons(QuestionViewModel viewModel) {
    return Positioned(
      bottom: 20,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!viewModel.isFirstQuestion)
            ElevatedButton(
              onPressed: viewModel.previousQuestion,
              child: const Text('Previous'),
            ),
          if (viewModel.hasAnsweredCurrentQuestion && !viewModel.isLastQuestion)
            ElevatedButton(
              onPressed: viewModel.nextQuestion,
              child: const Text('Next'),
            ),
          if (viewModel.hasAnsweredCurrentQuestion && viewModel.isLastQuestion)
            ElevatedButton(
              onPressed: () {
                print('Final answers: ${viewModel.answers}');
              },
              child: const Text('Finish'),
            ),
        ],
      ),
    );
  }
}
