import 'package:flutter/material.dart';

class AppTheme {
  // Colors
  static const Color primary = Color(0xFFFE5B13);
  static const Color backgroundLight = Color(0xFFF6F7F8);
  static const Color backgroundDark = Color(0xFF131111);
  static const Color surfaceDark = Color(0xFF232120);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color borderDark = Color(0xFF474747);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Old colors
  // static const Color primary = Color(0xFF13A4EC);
  // static const Color backgroundLight = Color(0xFFF6F7F8);
  // static const Color backgroundDark = Color(0xFF101C22);
  // static const Color surfaceDark = Color(0xFF192B33);
  // static const Color surfaceLight = Color(0xFFFFFFFF);
  // static const Color borderDark = Color(0xFF325567);
  // static const Color borderLight = Color(0xFFE5E7EB);
  
  // Text Colors
  static const Color textMainLight = Color(0xFF111418);
  static const Color textMainDark = Color(0xFFFFFFFF);
  static const Color textSubLight = Color.fromARGB(255, 152, 128, 112);
  static const Color textSubDark = Color.fromARGB(255, 201, 186, 170);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF67E8F9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Shadows
  static List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: primary.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Border Radius
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  
  // Spacing
  static const double spacingXSmall = 4.0;
  static const double spacingSmall = 8.0;
  static const double spacingMedium = 16.0;
  static const double spacingLarge = 24.0;
  static const double spacingXLarge = 32.0;
}

