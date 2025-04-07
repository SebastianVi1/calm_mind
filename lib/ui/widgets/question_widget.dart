import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:re_mind/ui/view/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WQuestionWidget extends StatefulWidget {
  final String question;
  final List<String> options;
  final PageController pageController;
  final String description;
  final int questionIndex;
  final List<int?> answers;
  final Function(int? answer) onAnswerChanged;

  const WQuestionWidget({
    super.key,
    required this.question,
    required this.options,
    required this.pageController,
    required this.description,
    // The index of the current question in the quiz
    required this.questionIndex,
    required this.answers,
    required this.onAnswerChanged,
  });

  @override
  State<WQuestionWidget> createState() => _WQuestionWidgetState();
}

class _WQuestionWidgetState extends State<WQuestionWidget> {
  int? selectedOptionIndex;

  @override
  void initState() {
    super.initState();
    // Get the answer if exists
    selectedOptionIndex = widget.answers[widget.questionIndex];
  }

  @override
  Widget build(BuildContext context) {
    var deviceHeight = MediaQuery.sizeOf(context).height;
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/questions_background.jpg'),
              fit: BoxFit.cover
            ),
          ),
          
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: 30),
                Text(
                  widget.question,
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                AnimatedTextKit(
                  isRepeatingAnimation: false,
                  animatedTexts: [
                    TypewriterAnimatedText(
                      widget.description,
                      speed: Duration(milliseconds: 100),
                      textAlign: TextAlign.center,
                      textStyle: Theme.of(context).textTheme.bodyLarge,

                    )
                  ],
                ),
                SizedBox(height: deviceHeight * .30),
        
                // Dynamic options
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: widget.options.asMap().entries.map((entry) {
                    int index = entry.key;
                    String opcion = entry.value;
                    bool isSelected = selectedOptionIndex == index;
        
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: SizedBox(
                        
                        child: ElevatedButton(
                          
                          style: ElevatedButton.styleFrom(
                            
                            padding: EdgeInsets.symmetric(vertical: 15),
                            backgroundColor: isSelected ? Colors.blue : Colors.purple,
                            textStyle: Theme.of(context).textTheme.labelLarge,
                            
                            elevation: 7,
                            minimumSize: Size(double.infinity, 50),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedOptionIndex = index;
                              widget.onAnswerChanged(index); // Save the answer
                            });
                          },
                          child: Text(opcion, style: Theme.of(context).textTheme.labelLarge),
                        ),
                      ),
                    );
                  }).toList(),
                ),
        
                SizedBox(height: 20),
        
                // Next button only if there is a answer selected
                if (selectedOptionIndex != null)
                  ElevatedButton(
                    
                    onPressed: () {
                      bool isLastQuestion = widget.questionIndex == widget.answers.length -1;
                      if (isLastQuestion) {
                        _completeOnboarding(context);
                      }
                      widget.pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text(
                      'Siguiente pregunta',
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ]
    );
  }
  Future<void> _completeOnboarding(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenOnboarding', true);
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(builder: (context) => HomeScreen()),
  );
}
}
