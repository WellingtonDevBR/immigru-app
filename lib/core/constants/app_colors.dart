import 'package:flutter/material.dart';

class AppColors {
  // Primary brand color (same in both themes)
  static const Color primaryColor = Color(0xFF2EAA76); // Green color
  
  // Dark theme colors
  static const Color darkBackground = Color(0xFF1A2234); // Dark blue/black background
  static const Color darkSurface = Color(0xFF2A3446); // Slightly lighter than background
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFF8A8D9F); // Grayish text
  static const Color darkDivider = Color(0xFF3A4456);
  
  // Light theme colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Color(0xFFF5F7FA); // Light gray for input fields
  static const Color lightTextPrimary = Color(0xFF333333); // Dark gray for primary text
  static const Color lightTextSecondary = Color(0xFF6B7280); // Medium gray for secondary text
  static const Color lightDivider = Color(0xFFE5E7EB);
  
  // Get colors based on theme brightness
  static Color background(Brightness brightness) => 
      brightness == Brightness.dark ? darkBackground : lightBackground;
      
  static Color surface(Brightness brightness) => 
      brightness == Brightness.dark ? darkSurface : lightSurface;
      
  static Color textPrimary(Brightness brightness) => 
      brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
      
  static Color textSecondary(Brightness brightness) => 
      brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
      
  static Color divider(Brightness brightness) => 
      brightness == Brightness.dark ? darkDivider : lightDivider;
}
