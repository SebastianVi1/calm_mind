import 'package:flutter/material.dart';

class OnBoardingViewmodel  extends ChangeNotifier{
    List<int?> answers = List.filled(3, null); 

   List<int?> getAnswers(){
    return answers;
    
   }
}