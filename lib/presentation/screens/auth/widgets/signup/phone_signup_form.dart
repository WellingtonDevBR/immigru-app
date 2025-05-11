import 'package:flutter/material.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/theme/app_colors.dart';

/// Phone signup form widget (placeholder for now)
class PhoneSignupForm extends StatelessWidget {
  final AuthState authState;
  final TabController tabController;

  const PhoneSignupForm({
    super.key,
    required this.authState,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.phone_android,
            size: 64,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
          const SizedBox(height: 16),
          Text(
            'Phone signup coming soon',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'This feature is under development',
            style: TextStyle(
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              tabController.animateTo(0); // Switch to email tab
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: primaryColor,
              side: BorderSide(color: primaryColor),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Use email instead'),
          ),
        ],
      ),
    );
  }
}
