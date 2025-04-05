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

  WQuestionWidget({
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
    var deviceWidth = MediaQuery.sizeOf(context).width;
    var deviceHeight = MediaQuery.sizeOf(context).height;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      color: Colors.green,
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
            Text(
              widget.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
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
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      textStyle: Theme.of(context).textTheme.bodyLarge,
                      padding: EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: isSelected ? Colors.blue : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.white)
                      ),
                      elevation: 3,
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedOptionIndex = index;
                        widget.onAnswerChanged(index); // Save the answer
                      });
                    },
                    child: Text(opcion, style: Theme.of(context).textTheme.bodyMedium?.copyWith(letterSpacing: 2,)),
                  ),
                );
              }).toList(),
            ),

            SizedBox(height: 20),

            // Next button only if there is a answer selected
            if (selectedOptionIndex != null)
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(Colors.lightGreen),
                  elevation: WidgetStatePropertyAll(3),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(color: Colors.blue, width: 2),
                    ),
                  )
                ),
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
                child: Text("Siguiente"),
              ),
          ],
        ),
      ),
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
