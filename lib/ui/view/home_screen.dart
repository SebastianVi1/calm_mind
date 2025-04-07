import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:re_mind/viewmodels/on_boarding_viewmodel.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('hola'),
          ElevatedButton(onPressed: ()=> print(Provider.of<OnBoardingViewmodel>(context, listen: false).getAnswers()), child: Text(' '))
        ],
      ),
    );
  }
}