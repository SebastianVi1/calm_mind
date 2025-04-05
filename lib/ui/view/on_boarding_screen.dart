import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/ui/widgets/question_widget.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';


class OnBoardingScreen extends StatefulWidget {
  OnBoardingScreen({super.key});

  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  
  List<Map<String, dynamic>> questions = [
    {"question": "Ejemplo de pregunta", "description": "Descripcion pregunta 1", "options": ["option1", "option2", "option3"]},
    {"question": "Ejemplo de pregunta2", "description": "Descripcion pregunta 1", "options": ["option1", "option2", "option3"]},
    {"question": "Ejemplo de pregunta3", "description": "Descripcion pregunta 1", "options": ["option1", "option2"]},
  ];

  @override
  Widget build(BuildContext context) {
  var answers = Provider.of<OnBoardingViewmodel>(context).answers;

    return Scaffold(
      backgroundColor: Colors.white70,
      body: PageView(
        controller: _pageController,
        children: List.generate(questions.length, (index) {
          return WQuestionWidget(
            pageController: _pageController,
            description: questions[index]["description"] ?? "",
            options: questions[index]['options'] ?? [""],
            question: questions[index]['question'] ?? "",
            questionIndex: index,
            answers: answers,
            onAnswerChanged: (int? answer) {
              setState(() {
                answers[index] = answer; // Actualiza la lista de respuestas
              });
            },
          );
        }),
      ),
    );
  }
}