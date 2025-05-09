import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/screens/auth/otp_verification_screen.dart';
import 'package:immigru/presentation/screens/auth/widgets/login/google_sign_in_button.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

/// Widget for phone login with country selection
class PhoneLoginButton extends StatefulWidget {
  final bool isDarkMode;
  final Color primaryColor;
  final AuthState state;
  final Function(BuildContext) onPhoneLogin;
  final Function(BuildContext) onGoogleSignIn;

  const PhoneLoginButton({
    Key? key,
    required this.isDarkMode,
    required this.primaryColor,
    required this.state,
    required this.onPhoneLogin,
    required this.onGoogleSignIn,
  }) : super(key: key);

  @override
  State<PhoneLoginButton> createState() => _PhoneLoginButtonState();
}

class _PhoneLoginButtonState extends State<PhoneLoginButton> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _completePhoneNumber = '';
  bool _isPhoneValid = false;
  bool _isOtpSent = false;
  bool _isVerifying = false; // Tracks when OTP verification is in progress
  final _formKey = GlobalKey<FormState>();
  String _initialCountryCode = 'US'; // Default country code

  @override
  void initState() {
    super.initState();
    _detectUserCountry();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }
  
  // Detect user's country based on device locale
  void _detectUserCountry() {
    try {
      final locale = WidgetsBinding.instance.window.locale.countryCode;
      if (locale != null && locale.isNotEmpty) {
        setState(() {
          _initialCountryCode = locale;
        });
      }
    } catch (e) {
      // Fallback to default US if there's an error
      print('Error detecting country: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.phone_android,
              size: 64,
              color: widget.primaryColor.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            Text(
              'Sign in with your phone number',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: widget.isDarkMode ? Colors.white : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _isOtpSent
                  ? 'Enter the 6-digit code sent to your phone'
                  : 'We\'ll send you a verification code to confirm your identity',
              style: TextStyle(
                fontSize: 14,
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Phone number input with country selection (visible when OTP not sent)
            if (!_isOtpSent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: IntlPhoneField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    labelStyle: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.isDarkMode ? Colors.white30 : Colors.black12,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                      color: widget.isDarkMode ? Colors.white30 : Colors.black12,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.primaryColor,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: widget.isDarkMode 
                      ? Colors.grey.withOpacity(0.1) 
                      : Colors.grey.withOpacity(0.05),
                ),
                initialCountryCode: _initialCountryCode,
                onChanged: (phone) {
                  // Save the complete phone number with country code
                  _completePhoneNumber = phone.completeNumber;
                  setState(() {
                    _isPhoneValid = phone.number.length >= 6;
                  });
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  if (phone.number.length < 8) {
                    return 'Please enter a valid phone number';
                  }
                  return null;
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            // OTP input field (visible after OTP is sent)
            if (_isOtpSent)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: 12,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: InputDecoration(
                      hintText: '• • • • • •',
                      hintStyle: TextStyle(
                        color: widget.isDarkMode ? Colors.white54 : Colors.black38,
                        letterSpacing: 12,
                        fontSize: 22,
                      ),
                      filled: true,
                      fillColor: widget.isDarkMode 
                          ? Colors.grey.withOpacity(0.1) 
                          : Colors.grey.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.primaryColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: widget.primaryColor,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: widget.isDarkMode ? Colors.white54 : Colors.black38,
                        size: 22,
                      ),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the verification code';
                      }
                      if (value.length < 6) {
                        return 'Please enter a valid verification code';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              
            const SizedBox(height: 24),
            
            // Login/Verify button
            SizedBox(
              width: double.infinity, // Make button full width
              height: 50, // Fixed height for consistency
            child: ElevatedButton(
              onPressed: widget.state.isLoading || _isVerifying
                  ? null // Disable button while loading or verifying
                  : _isPhoneValid
                      ? () {
                          if (_formKey.currentState!.validate()) {
                            // Set verifying state to true
                            setState(() {
                              _isVerifying = true;
                            });
                            
                            // Use the AuthBloc to send OTP
                            print('Sending OTP to: $_completePhoneNumber'); // For debugging
                            context.read<AuthBloc>().add(
                              AuthSendOtpEvent(
                                phone: _completePhoneNumber,
                              ),
                            );
                            
                            // Navigate to OTP verification screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OtpVerificationScreen(
                                  phoneNumber: _completePhoneNumber,
                                ),
                              ),
                            );
                            
                            // Reset verifying state
                            setState(() {
                              _isVerifying = false;
                            });
                          }
                        }
                      : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: widget.primaryColor.withOpacity(0.6),
              ),
              child: widget.state.isLoading || _isVerifying
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
            
          const SizedBox(height: 24),
            
          // OR divider
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: widget.isDarkMode ? Colors.white30 : Colors.black12,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'OR',
                    style: TextStyle(
                      fontSize: 12,
                      color: widget.isDarkMode ? Colors.white54 : Colors.black45,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: widget.isDarkMode ? Colors.white30 : Colors.black12,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Google sign-in button
            GoogleSignInButton(
              isLoading: widget.state.isLoading,
              onPressed: () => widget.onGoogleSignIn(context),
              isDarkMode: widget.isDarkMode,
            ),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
