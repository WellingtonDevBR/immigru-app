import 'package:flutter/material.dart';
import 'package:immigru/core/utils/input_validation.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Widget to display password requirements and validation status
class PasswordRequirementsWidget extends StatelessWidget {
  /// The current password value
  final String password;
  
  /// Whether to show the requirements
  final bool visible;
  
  /// Constructor
  const PasswordRequirementsWidget({
    Key? key,
    required this.password,
    this.visible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();
    
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // Get password requirements status
    final requirements = InputValidation().checkPasswordRequirements(password);
    
    return AnimatedOpacity(
      opacity: visible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 8.0, bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isDarkMode 
              ? Colors.grey.shade800.withOpacity(0.5) 
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isDarkMode 
                ? Colors.grey.shade700 
                : Colors.grey.shade300,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password Requirements:',
              style: AppTextStyles.bodySmall(brightness: brightness).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            _buildRequirementRow(
              context, 
              'At least ${InputValidation.minPasswordLength} characters', 
              requirements['length'] ?? false,
            ),
            _buildRequirementRow(
              context, 
              'At least one uppercase letter (A-Z)', 
              requirements['uppercase'] ?? false,
            ),
            _buildRequirementRow(
              context, 
              'At least one lowercase letter (a-z)', 
              requirements['lowercase'] ?? false,
            ),
            _buildRequirementRow(
              context, 
              'At least one number (0-9)', 
              requirements['number'] ?? false,
            ),
            _buildRequirementRow(
              context, 
              'At least one special character (!@#\$%^&*)', 
              requirements['special'] ?? false,
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a requirement row with an icon indicating status
  Widget _buildRequirementRow(BuildContext context, String text, bool isMet) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            size: 16.0,
            color: isMet 
                ? (isDarkMode ? Colors.green.shade300 : Colors.green) 
                : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodySmall(brightness: brightness).copyWith(
                color: isMet 
                    ? (isDarkMode ? Colors.green.shade300 : Colors.green) 
                    : (isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
