import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:calm_mind/models/question_model.dart';
import 'package:calm_mind/ui/constants/app_constants.dart';
import 'package:calm_mind/ui/view/main_screen.dart';
import 'package:calm_mind/viewmodels/question_view_model.dart';
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
    
    return AnimatedContainer(
      curve: Curves.decelerate,
      duration: const Duration(milliseconds: 300),
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildContent(deviceHeight),
          _buildNavigationButtons(viewModel),
        ],
      ),
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
            const SizedBox(height: 30),
            _buildOptions(),
          ],
        ),
      ),
    );
  }

  /// Builds the question text with proper styling
  Widget _buildQuestionText() {
    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 300),
      style: Theme.of(context).textTheme.displaySmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ) ?? const TextStyle(),
      child: Text(
        widget.question.question,
        textAlign: TextAlign.center,
      ),
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
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        )
      ],
    );
  }

  /// Builds the list of option buttons
  Widget _buildOptions() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: widget.question.options.asMap().entries.map((entry) {
        final option = entry.value;
        final isSelected = widget.selectedAnswer == option;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => widget.onAnswerChanged(option),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.surface,
                foregroundColor: isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
                elevation: isSelected ? 4 : 2,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.primary.withOpacity(0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ) ?? const TextStyle(),
                child: Text(
                  option,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Builds the navigation buttons (previous and next)
  Widget _buildNavigationButtons(QuestionViewModel viewModel) {
    return Positioned(
      bottom: 20,
      left: 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.contentHorizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Previous button
            if (!viewModel.isFirstQuestion)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ElevatedButton(
                    onPressed: () => viewModel.previousQuestion(),
                    style: ButtonStyle(
                      
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      
                      
                      elevation: WidgetStateProperty.all(0),
                      minimumSize: WidgetStateProperty.all(const Size(120, 48)),
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: const Text('Anterior'),
                  ),
                ),
              ),
            // Next button
            if (viewModel.hasAnsweredCurrentQuestion && !viewModel.isLastQuestion)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: () => viewModel.nextQuestion(),
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1A1A)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0),
                      minimumSize: WidgetStateProperty.all(const Size(120, 48)),
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: const Text('Siguiente'),
                  ),
                ),
              ),
            // Finish button (only on last question)
            if (viewModel.isLastQuestion && viewModel.hasAnsweredCurrentQuestion)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        await viewModel.saveAnswers();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MainScreen(),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(const Color(0xFF1A1A1A)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                      shape: WidgetStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      elevation: WidgetStateProperty.all(0),
                      minimumSize: WidgetStateProperty.all(const Size(120, 48)),
                      textStyle: WidgetStateProperty.all(
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    child: const Text('Finalizar'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
