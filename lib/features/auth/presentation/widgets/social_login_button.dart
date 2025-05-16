import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Button for social login options
class SocialLoginButton extends StatelessWidget {
  /// Text to display on the button
  final String text;
  
  /// Path to the icon image
  final String icon;
  
  /// Callback for when the button is pressed
  final VoidCallback? onPressed;
  
  /// Constructor
  const SocialLoginButton({
    Key? key,
    required this.text,
    required this.icon,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final brightness = isDarkMode ? Brightness.dark : Brightness.light;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white24 : Colors.black12,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon.endsWith('.svg')
                ? SvgPicture.asset(
                    icon,
                    width: 24,
                    height: 24,
                  )
                : Image.asset(
                    icon,
                    width: 24,
                    height: 24,
                  ),
              const SizedBox(width: 12),
              Text(
                text,
                style: AppTextStyles.buttonMedium(brightness: brightness).copyWith(
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
