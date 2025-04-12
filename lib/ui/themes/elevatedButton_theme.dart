import 'package:flutter/material.dart';

class TElevatedbuttonTheme {
  static final ElevatedButtonThemeData elevatedButtonLightTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStatePropertyAll(7),
      backgroundColor: WidgetStatePropertyAll(Color(0xFF7EA8BE)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.white,
            width: 2,
            style: BorderStyle.solid,
          )
          
        ),
        
      )
    )
  );
}