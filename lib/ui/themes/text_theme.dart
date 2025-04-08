import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
abstract class TTextTheme {
  TTextTheme._();
  static final textTheme = TextTheme(
    bodyMedium: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
    ),
    bodyLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w500,
    ),
    titleLarge: GoogleFonts.robotoMono(
      
    ),
    displayLarge: GoogleFonts.satisfy(
      fontWeight: FontWeight.w600
    ),
    displaySmall: GoogleFonts.montserrat(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      
    ),
    labelLarge: GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: Colors.white
    )
  );
  
}