import 'package:flutter/material.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final bool showText;
  
  const AppLogo({
    Key? key,
    this.height = 32,
    this.showText = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDarkMode ? AppColors.primaryDark : AppColors.primaryLight;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo image
        Image.asset(
          'assets/icons/immigru-logo.png',
          height: height,
          width: height,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to icon if image fails to load
            return Icon(
              Icons.eco_rounded,
              color: primaryColor,
              size: height,
            );
          },
        ),
        
        // App name text
        if (showText) ...[  
          const SizedBox(width: 8),
          Text(
            'Immigru',
            style: TextStyle(
              color: primaryColor,
              fontSize: height * 0.6,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
