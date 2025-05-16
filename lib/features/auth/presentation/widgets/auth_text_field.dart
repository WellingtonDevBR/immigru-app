import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Custom text field for authentication screens
class AuthTextField extends StatelessWidget {
  /// Controller for the text field
  final TextEditingController controller;
  
  /// Label text
  final String label;
  
  /// Hint text
  final String hint;
  
  /// Whether to obscure text (for passwords)
  final bool obscureText;
  
  /// Keyboard type
  final TextInputType keyboardType;
  
  /// Prefix icon
  final IconData? prefixIcon;
  
  /// Suffix icon
  final IconData? suffixIcon;
  
  /// Callback for when the suffix icon is tapped
  final VoidCallback? onSuffixIconTap;
  
  /// Validator function
  final String? Function(String?)? validator;

  /// Constructor
  const AuthTextField({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.label(brightness: Theme.of(context).brightness).copyWith(
            color: AppColors.textSecondary(Theme.of(context).brightness),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyLarge(brightness: Theme.of(context).brightness),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyLarge(brightness: Theme.of(context).brightness).copyWith(
              color: AppColors.textSecondary(Theme.of(context).brightness).withValues(alpha:0.7),
            ),
            filled: true,
            fillColor: isDarkMode ? AppColors.surfaceDark : AppColors.surfaceLight,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.border(Theme.of(context).brightness),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.error,
                width: 2,
              ),
            ),
            prefixIcon: prefixIcon != null
                ? Icon(
                    prefixIcon,
                    color: AppColors.textSecondary(Theme.of(context).brightness),
                  )
                : null,
            suffixIcon: suffixIcon != null
                ? GestureDetector(
                    onTap: onSuffixIconTap,
                    child: Icon(
                      suffixIcon,
                      color: AppColors.textSecondary(Theme.of(context).brightness),
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
