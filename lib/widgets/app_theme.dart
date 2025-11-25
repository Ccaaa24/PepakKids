import 'package:flutter/material.dart';

// Enhanced App Theme Constants untuk konsistensi UI
class AppTheme {
  // Color Palette - Enhanced untuk aplikasi edukasi anak
  static const Color primaryBrown = Color(0xFFA97142);
  static const Color lightBrown = Colors.brown;
  static const Color textSecondary = Colors.black54;
  static const Color cardBackground = Colors.white;
  
  // Enhanced colors untuk Quiz & Result
  static const Color quizPrimary = Color(0xFF4A90E2);
  static const Color quizSecondary = Color(0xFF7BB3F0);
  static const Color resultSuccess = Color(0xFF4CAF50);
  static const Color resultWarning = Color(0xFFFF9800);
  static const Color resultError = Color(0xFFF44336);
  static const Color starColor = Color(0xFFFFD700);
  
  // Layout Constants
  static const double borderRadius = 20.0;
  static const double buttonBorderRadius = 30.0;
  static const double cardPadding = 24.0;
  static const double defaultSpacing = 20.0;
  static const double smallSpacing = 15.0;
  static const double tinySpacing = 10.0;
  
  // Typography
  static const double titleFontSize = 24.0;
  static const double titleFontSizeSmall = 20.0;
  static const double subtitleFontSize = 18.0;
  static const double buttonFontSize = 16.0;
  static const double bodyFontSize = 14.0;
  
  // Enhanced shadows
  static BoxShadow get cardShadow => BoxShadow(
    color: Colors.black.withOpacity(0.1),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
  
  static BoxShadow get buttonShadow => BoxShadow(
    color: Colors.black.withOpacity(0.15),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );
}
