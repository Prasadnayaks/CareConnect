// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor =
      Color(0xFFE8F5E9); // Very light green, almost off-white
  static const Color accentColor =
      Color(0xFF4CAF50); // Vibrant Green (like the button in Aivo)
  static const Color backgroundColor = Colors.white; // Clean white background
  static const Color textColor =
      Color(0xFF333333); // Dark grey for text for readability

  static const Color userBubbleColor =
      Color(0xFF66BB6A); // A slightly softer green for user
  static const Color userBubbleTextColor = Colors.white;

  static const Color modelBubbleColor =
      Color(0xFFF1F8E9); // Very light green for model bubble
  static const Color modelBubbleTextColor =
      Color(0xFF333333); // Dark text for model

  static const Color inputBackgroundColor =
      Color(0xFFF5F5F5); // Light grey for input field background
  static const Color hintTextColor = Colors.grey;
  static const Color iconColor =
      Color(0xFF388E3C); // Darker Green for icons (or use accentColor)

  static const Color errorColor = Colors.redAccent;
  static const Color infoColor = Colors.blueAccent;
  static const Color typingIndicatorColor = Colors.grey;
  static const Color appBarTextColor =
      Color(0xFF2E7D32); // Dark Green for AppBar title
  static const Color sendButtonColor =
      Color(0xFF4CAF50); // Vibrant Green for send button
}
