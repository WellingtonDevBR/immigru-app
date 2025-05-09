import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A reusable social login button widget that can be used across
/// login and signup screens.
class SocialLoginButton extends StatelessWidget {
  /// The social platform name (e.g., 'Google', 'Apple')
  final String platform;
  
  /// The logo URL or asset path for the social platform
  final String? logoPath;
  
  /// Whether the logo is a network image or an asset
  final bool isNetworkImage;
  
  /// Callback function when the button is pressed
  final VoidCallback onPressed;
  
  /// Whether the button is in a loading state
  final bool isLoading;

  /// Custom icon widget to use instead of loading from path
  final Widget? icon;

  /// Button text override
  final String? buttonText;

  /// Custom button style
  final ButtonStyle? buttonStyle;

  /// The social platform type (used for predefined icons)
  final SocialPlatform socialPlatform;

  const SocialLoginButton({
    Key? key,
    required this.platform,
    this.logoPath,
    this.isNetworkImage = false,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.buttonText,
    this.buttonStyle,
    this.socialPlatform = SocialPlatform.custom,
  }) : super(key: key);

  /// Factory constructor for Google login button
  factory SocialLoginButton.google({
    required VoidCallback onPressed,
    bool isLoading = false,
    ButtonStyle? buttonStyle,
    String? buttonText,
  }) {
    return SocialLoginButton(
      platform: 'Google',
      socialPlatform: SocialPlatform.google,
      onPressed: onPressed,
      isLoading: isLoading,
      buttonStyle: buttonStyle,
      buttonText: buttonText,
    );
  }

  /// Factory constructor for Apple login button
  factory SocialLoginButton.apple({
    required VoidCallback onPressed,
    bool isLoading = false,
    ButtonStyle? buttonStyle,
    String? buttonText,
  }) {
    return SocialLoginButton(
      platform: 'Apple',
      socialPlatform: SocialPlatform.apple,
      onPressed: onPressed,
      isLoading: isLoading,
      buttonStyle: buttonStyle,
      buttonText: buttonText,
    );
  }
  
  /// Factory constructor for Phone login button
  factory SocialLoginButton.phone({
    required VoidCallback onPressed,
    bool isLoading = false,
    ButtonStyle? buttonStyle,
    String? buttonText,
  }) {
    return SocialLoginButton(
      platform: 'Phone',
      socialPlatform: SocialPlatform.phone,
      onPressed: onPressed,
      isLoading: isLoading,
      buttonStyle: buttonStyle,
      buttonText: buttonText ?? 'Sign in with Phone',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: buttonStyle ?? OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        side: BorderSide(
          color: isDarkMode ? Colors.white30 : Colors.black12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: isDarkMode ? Colors.black12 : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              height: 24,
              width: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isDarkMode ? Colors.white70 : Colors.black45,
                ),
              ),
            )
          else if (icon != null)
            icon!
          else if (socialPlatform == SocialPlatform.google)
            SvgPicture.asset(
              'assets/icons/google_logo.svg',
              height: 24,
              width: 24,
            )
          else if (socialPlatform == SocialPlatform.apple)
            Icon(
              Icons.apple,
              size: 24,
              color: isDarkMode ? Colors.white : Colors.black,
            )
          else if (socialPlatform == SocialPlatform.phone)
            Icon(
              Icons.phone_android,
              size: 24,
              color: isDarkMode ? Colors.white70 : Colors.black87,
            )
          else if (isNetworkImage && logoPath != null)
            Image.network(
              logoPath!,
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error_outline,
                  size: 24,
                  color: isDarkMode ? Colors.white70 : Colors.black45,
                );
              },
            )
          else if (logoPath != null)
            Image.asset(
              logoPath!,
              height: 24,
              width: 24,
              errorBuilder: (context, error, stackTrace) {
                return Icon(
                  Icons.error_outline,
                  size: 24,
                  color: isDarkMode ? Colors.white70 : Colors.black45,
                );
              },
            ),
          const SizedBox(width: 12),
          Text(
            isLoading ? 'Please wait...' : buttonText ?? 'Continue with $platform',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

/// Enum for predefined social platforms
enum SocialPlatform {
  google,
  apple,
  facebook,
  twitter,
  phone,
  custom,
}
