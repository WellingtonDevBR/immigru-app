import 'package:flutter/material.dart';

/// Modern app logo widget
class AppLogo extends StatelessWidget {
  final double height;
  final bool showText;

  const AppLogo({
    super.key,
    this.height = 32,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo icon
        Container(
          height: height,
          width: height,
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Image.asset(
            'assets/icons/logo.png',
            fit: BoxFit.contain,
          ),
        ),

        // Logo text
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'Immigru',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: height * 0.7,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
