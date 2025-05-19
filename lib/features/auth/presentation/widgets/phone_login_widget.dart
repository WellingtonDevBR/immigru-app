import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_button.dart';
import 'package:immigru/features/auth/presentation/widgets/social_login_button.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

// Global key to access the state of PhoneLoginWidget from outside
final GlobalKey<_PhoneLoginWidgetState> phoneLoginWidgetKey = GlobalKey<_PhoneLoginWidgetState>();

/// Widget for phone login form with country selection
class PhoneLoginWidget extends StatefulWidget {
  /// Controller for phone number input
  final TextEditingController phoneController;
  
  /// Whether the app is in dark mode
  final bool isDarkMode;
  
  /// Current auth state
  final AuthState state;
  
  /// Callback for phone login
  final VoidCallback onPhoneLogin;
  
  /// Callback for Google sign in
  final VoidCallback onGoogleSignIn;
  
  /// Get the currently selected country code
  String getCountryCode() {
    final state = phoneLoginWidgetKey.currentState;
    return state != null ? state._countryCode : '+1';
  }

  /// Constructor
  const PhoneLoginWidget({
    super.key,
    required this.phoneController,
    required this.isDarkMode,
    required this.state,
    required this.onPhoneLogin,
    required this.onGoogleSignIn,
  });
  
  @override
  State<PhoneLoginWidget> createState() => _PhoneLoginWidgetState();
}

class _PhoneLoginWidgetState extends State<PhoneLoginWidget> {
  final FocusNode _phoneFocusNode = FocusNode();
  String _countryCode = '+1'; // Default US country code
  
  /// Get the currently selected country code
  String getCountryCode() {
    return _countryCode;
  }

  @override
  void initState() {
    super.initState();
    
    // Clear the phone controller to avoid any previous values
    if (widget.phoneController.text.isNotEmpty) {
      widget.phoneController.clear();
    }
  }
  
  @override
  void dispose() {
    _phoneFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = widget.isDarkMode;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Phone number field with country selection
        Text(
          'Phone Number',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country code dropdown
            Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.withValues(alpha:0.1)
                    : Colors.grey.withValues(alpha:0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.white30 : Colors.black12,
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _countryCode,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  dropdownColor: isDarkMode ? Colors.grey[900] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  items: [
                    DropdownMenuItem(value: '+1', child: Text('+1 🇺🇸')),
                    DropdownMenuItem(value: '+44', child: Text('+44 🇬🇧')),
                    DropdownMenuItem(value: '+61', child: Text('+61 🇦🇺')),
                    DropdownMenuItem(value: '+55', child: Text('+55 🇧🇷')),
                    DropdownMenuItem(value: '+86', child: Text('+86 🇨🇳')),
                    DropdownMenuItem(value: '+91', child: Text('+91 🇮🇳')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      if (kDebugMode) {

                      }
                      setState(() {
                        _countryCode = value;
                      });
                    }
                  },
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Phone number input field
            Expanded(
              child: TextFormField(
                controller: widget.phoneController,
                focusNode: _phoneFocusNode,
                keyboardType: TextInputType.phone,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter your phone number',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                  filled: true,
                  fillColor: isDarkMode
                      ? Colors.grey.withValues(alpha:0.1)
                      : Colors.grey.withValues(alpha:0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white30 : Colors.black12,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.white30 : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  prefixIcon: Icon(
                    Icons.phone_android,
                    color: isDarkMode ? Colors.white54 : Colors.black38,
                  ),
                ),
                onChanged: (value) {
                  if (kDebugMode) {

                  }
                },
                inputFormatters: [
                  // Only allow digits for phone number
                  FilteringTextInputFormatter.digitsOnly,
                  // Limit length to prevent excessive input (max 15 digits for international numbers)
                  LengthLimitingTextInputFormatter(15),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  
                  // Validate phone number length (without country code)
                  if (value.length < 6 || value.length > 12) {
                    return 'Please enter a valid phone number';
                  }
                  
                  return null;
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Login button
        AuthButton(
          text: 'Continue with Phone',
          isLoading: widget.state.isLoading,
          onPressed: widget.onPhoneLogin,
        ),
        
        const SizedBox(height: 24),
        
        // Divider
        Row(
          children: [
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.white30 : Colors.black12,
                thickness: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'OR',
                style: AppTextStyles.bodySmall(
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ).copyWith(
                  color: isDarkMode ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
            Expanded(
              child: Divider(
                color: isDarkMode ? Colors.white30 : Colors.black12,
                thickness: 1,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Google sign in button
        SocialLoginButton(
          text: 'Continue with Google',
          icon: 'assets/icons/google_logo.svg',
          onPressed: widget.onGoogleSignIn,
        ),
        
        const SizedBox(height: 16),
        
        // Phone verification info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDarkMode 
                ? Colors.grey.withValues(alpha:0.1) 
                : Colors.grey.withValues(alpha:0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDarkMode ? Colors.white12 : Colors.black12,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Phone Verification',
                    style: AppTextStyles.bodyMedium(
                      brightness: isDarkMode ? Brightness.dark : Brightness.light,
                    ).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'We will send a verification code to your phone number. Standard message rates may apply.',
                style: AppTextStyles.bodySmall(
                  brightness: isDarkMode ? Brightness.dark : Brightness.light,
                ).copyWith(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
