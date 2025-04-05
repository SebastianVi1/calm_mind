import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
abstract class TTextTheme {
  TTextTheme._();
  static final textTheme = TextTheme(
    bodyMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.robotoMono(
      
    )
    
  );
  
}