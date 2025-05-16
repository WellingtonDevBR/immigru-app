import 'package:flutter/material.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';
import 'package:flutter/services.dart';

/// Widget for displaying error messages with a dismiss option
class ErrorMessageWidget extends StatefulWidget {
  /// The error message to display
  final String message;

  /// The error code for categorizing errors
  final String? errorCode;

  /// Callback when the close button is pressed
  final VoidCallback? onClose;

  /// Whether to show a haptic feedback when displaying the error
  final bool withHapticFeedback;

  /// Constructor
  const ErrorMessageWidget({
    super.key,
    required this.message,
    this.errorCode,
    this.onClose,
    this.withHapticFeedback = true,
  });

  @override
  State<ErrorMessageWidget> createState() => _ErrorMessageWidgetState();
}

class _ErrorMessageWidgetState extends State<ErrorMessageWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Auto-dismiss the error message after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _handleClose();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleClose() {
    if (!_isVisible) return;

    setState(() {
      _isVisible = false;
    });

    _animationController.forward().then((_) {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;

    // Provide haptic feedback for errors
    if (widget.withHapticFeedback) {
      HapticFeedback.mediumImpact();
    }

    // Determine colors based on error code
    final (Color bgColor, Color borderColor, Color iconColor, IconData icon) =
        _getErrorStyling(widget.errorCode, isDarkMode);

    // Add a fade animation for smooth dismissal
    return FadeTransition(
      opacity: _opacityAnimation,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity, // Take full width
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.symmetric(
            horizontal: 16.0, vertical: 16.0), // More padding
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: borderColor,
            width: 2.0, // Thicker border for emphasis
          ),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.4),
              blurRadius: 8.0,
              offset: const Offset(0, 3),
              spreadRadius: 1.0,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.errorCode != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Text(
                        _getErrorTitle(widget.errorCode!),
                        style: AppTextStyles.bodyMedium(brightness: brightness)
                            .copyWith(
                          color: isDarkMode
                              ? Colors.white
                              : _getTextColor(widget.errorCode),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  Text(
                    widget.message,
                    style: AppTextStyles.bodyMedium(brightness: brightness)
                        .copyWith(
                      color: isDarkMode
                          ? Colors.white
                          : _getTextColor(widget.errorCode),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: _handleClose,
              icon: Icon(
                Icons.close,
                color: isDarkMode ? Colors.white70 : iconColor,
                size: 18,
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }

  /// Get the error styling based on the error code
  (Color, Color, Color, IconData) _getErrorStyling(
      String? code, bool isDarkMode) {
    if (code == null) {
      return (
        isDarkMode
            ? Colors.red.shade900.withValues(alpha: 0.7)
            : Colors.red.shade50,
        Colors.red.shade300,
        Colors.red.shade300,
        Icons.error_outline
      );
    }

    switch (code) {
      case 'network_error':
        return (
          isDarkMode
              ? Colors.orange.shade900.withValues(alpha: 0.7)
              : Colors.orange.shade50,
          Colors.orange.shade300,
          Colors.orange.shade300,
          Icons.wifi_off_rounded
        );
      case 'invalid_credentials':
        return (
          isDarkMode
              ? Colors.red.shade900.withValues(alpha: 0.7)
              : Colors.red.shade50,
          Colors.red.shade300,
          Colors.red.shade300,
          Icons.lock_outline
        );
      case 'invalid_otp':
      case 'verification_failed':
        return (
          isDarkMode
              ? Colors.red.shade900.withValues(alpha: 0.7)
              : Colors.red.shade50,
          Colors.red.shade300,
          Colors.red.shade300,
          Icons.lock_outline
        );
      case 'email_already_in_use':
        return (
          isDarkMode
              ? Colors.purple.shade900.withValues(alpha: 0.7)
              : Colors.purple.shade50,
          Colors.purple.shade300,
          Colors.purple.shade300,
          Icons.email_outlined
        );
      // Password-related errors
      case 'weak_password':
      case 'password_too_short':
      case 'password_complexity':
        return (
          isDarkMode
              ? Colors.amber.shade900.withValues(alpha: 0.7)
              : Colors.amber.shade50,
          Colors.amber.shade300,
          Colors.amber.shade300,
          Icons.security_outlined
        );
      case 'password_mismatch':
        return (
          isDarkMode
              ? Colors.deepOrange.shade900.withValues(alpha: 0.7)
              : Colors.deepOrange.shade50,
          Colors.deepOrange.shade300,
          Colors.deepOrange.shade300,
          Icons.difference_outlined
        );
      case 'too_many_requests':
        return (
          isDarkMode
              ? Colors.blue.shade900.withValues(alpha: 0.7)
              : Colors.blue.shade50,
          Colors.blue.shade300,
          Colors.blue.shade300,
          Icons.timer_outlined
        );
      default:
        return (
          isDarkMode
              ? Colors.red.shade900.withValues(alpha: 0.7)
              : Colors.red.shade50,
          Colors.red.shade300,
          Colors.red.shade300,
          Icons.error_outline
        );
    }
  }

  /// Get the text color based on the error code
  Color _getTextColor(String? code) {
    if (code == null) return Colors.red.shade700;

    switch (code) {
      case 'network_error':
        return Colors.orange.shade700;
      case 'email_already_in_use':
        return Colors.purple.shade700;
      case 'weak_password':
        return Colors.amber.shade800;
      case 'too_many_requests':
        return Colors.blue.shade700;
      default:
        return Colors.red.shade700;
    }
  }

  /// Get a user-friendly title based on the error code
  String _getErrorTitle(String code) {
    switch (code) {
      case 'network_error':
        return 'Connection Error';
      case 'invalid_credentials':
        return 'Authentication Failed';
      case 'invalid_otp':
      case 'verification_failed':
        return 'Verification Failed';
      case 'email_already_in_use':
        return 'Email Already Registered';
      case 'weak_password':
        return 'Password Too Weak';
      case 'password_too_short':
        return 'Password Too Short';
      case 'password_complexity':
        return 'Password Requirements';
      case 'password_mismatch':
        return 'Passwords Do Not Match';
      case 'too_many_requests':
        return 'Too Many Attempts';
      case 'user_not_found':
        return 'User Not Found';
      case 'google_sign_in_cancelled':
        return 'Sign In Cancelled';
      case 'google_sign_in_failed':
        return 'Google Sign In Failed';
      case 'phone_verification_failed':
        return 'Phone Verification Failed';
      case 'signup_failed':
        return 'Registration Failed';
      default:
        return 'Error';
    }
  }
}
