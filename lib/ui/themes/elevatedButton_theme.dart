import 'package:flutter/material.dart';

class TElevatedbuttonTheme {
  static final ElevatedButtonThemeData elevatedButtonLightTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      elevation: WidgetStatePropertyAll(7),
      backgroundColor: WidgetStatePropertyAll(Colors.purple),
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