import 'package:flutter/material.dart';

@immutable
class AppColors {
  // --- Brand Colors ---
  final Color primary = const Color(0xFF4CAF50); // Green (Growth, health)
  final Color accent = const Color(0xFFFF9800); // Orange (Action, alerts)

  // --- Neutrals / UI Colors ---
  final Color textBody = const Color(0xFF212121); // Dark grey for main text
  final Color textCaption = const Color(0xFF7D7873); // Muted caption text
  final Color surface = const Color(0xFFF5F5DC); // Beige / Off-white background
  final Color white = Colors.white; // White
  final Color black = const Color(0xFF1E1B18); // Near black for contrast
  final Color greyLight = Colors.grey.shade300; // Light grey for borders
  final Color greyMedium = const Color(0xFF9D9995); // Medium grey for UI elements

  // --- Feedback Colors ---
  final Color error = const Color(0xFFD32F2F); // Red (Critical errors)
  final Color success = const Color(0xFF388E3C); // Dark Green (Success)
}
