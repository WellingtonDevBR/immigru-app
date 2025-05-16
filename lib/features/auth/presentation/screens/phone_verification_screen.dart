import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_event.dart';
import 'package:immigru/features/auth/presentation/bloc/auth_state.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_button.dart';
import 'package:immigru/features/auth/presentation/widgets/auth_header.dart';
import 'package:immigru/features/auth/presentation/widgets/error_message_widget.dart';
import 'package:immigru/shared/theme/app_colors.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Screen for verifying phone number with OTP code
class PhoneVerificationScreen extends StatefulWidget {
  /// Route name for navigation
  static const routeName = '/verify-phone';

  /// Phone number to verify
  final String phoneNumber;

  /// Constructor
  const PhoneVerificationScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<PhoneVerificationScreen> createState() => _PhoneVerificationScreenState();
}

class _PhoneVerificationScreenState extends State<PhoneVerificationScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );
  final List<String> _otpValues = List.filled(6, '');
  
  Timer? _resendTimer;
  int _remainingTime = 60;
  bool _canResend = false;
  String? _errorMessage;
  String? _errorCode;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _resendTimer?.cancel();
    super.dispose();
  }
  
  void _dismissError() {
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
  }

  void _startResendTimer() {
    setState(() {
      _remainingTime = 60;
      _canResend = false;
      _errorMessage = null;
      _errorCode = null;
    });
    
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  void _handleResendCode() {
    // Clear any previous errors
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
    
    if (_canResend) {
      context.read<AuthBloc>().add(
            AuthStartPhoneAuthEvent(
              phoneNumber: widget.phoneNumber,
            ),
          );
      _startResendTimer();
    }
  }

  void _handleVerifyCode() {
    // Clear any previous errors
    setState(() {
      _errorMessage = null;
      _errorCode = null;
    });
    
    final code = _otpValues.join();
    if (code.length == 6) {
      if (kDebugMode) {
        print('Verifying code for phone number: ${widget.phoneNumber}');
      }
      context.read<AuthBloc>().add(
            AuthVerifyPhoneCodeEvent(
              verificationId: widget.phoneNumber, // Using phone number as verification ID
              code: code,
            ),
          );
    } else {
      setState(() {
        _errorMessage = 'Please enter all 6 digits of the verification code';
        _errorCode = 'incomplete_code';
      });
    }
  }

  void _onOtpDigitChanged(int index, String value) {
    if (value.isNotEmpty) {
      _otpValues[index] = value;
      
      // Move to next field if not the last one
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        // Last field filled, remove focus
        FocusScope.of(context).unfocus();
        
        // Auto-verify when all digits are filled
        _handleVerifyCode();
      }
    } else {
      _otpValues[index] = '';
    }
  }

  void _onKeyEvent(int index, RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.backspace && 
          _controllers[index].text.isEmpty && 
          index > 0) {
        // Move to previous field on backspace if current field is empty
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.isAuthenticated) {
            if (state.user?.hasCompletedOnboarding ?? false) {
              Navigator.of(context).pushReplacementNamed('/home');
            } else {
              Navigator.of(context).pushReplacementNamed('/onboarding');
            }
          }

          if (state.errorMessage != null) {
            setState(() {
              _errorMessage = state.errorMessage;
              _errorCode = state.errorCode;
            });
          }
        },
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  
                  // Display error message if there is one
                  if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ErrorMessageWidget(
                        message: _errorMessage!,
                        errorCode: _errorCode,
                        onClose: _dismissError,
                      ),
                    ),
                  
                  const SizedBox(height: 16),
                  _buildOtpFields(),
                  const SizedBox(height: 24),
                  _buildResendOption(),
                  const SizedBox(height: 40),
                  _buildVerifyButton(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthHeader(
          title: 'Verify Your Phone',
          isDarkMode: isDarkMode,
          primaryColor: primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ve sent a verification code to ${widget.phoneNumber}',
          style: AppTextStyles.bodyLarge(brightness: Theme.of(context).brightness).copyWith(
            color: AppColors.textSecondary(Theme.of(context).brightness),
          ),
        ),
      ],
    );
  }

  Widget _buildOtpFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: 45,
          height: 55,
          child: RawKeyboardListener(
            focusNode: FocusNode(),
            onKey: (event) => _onKeyEvent(index, event),
            child: TextFormField(
              controller: _controllers[index],
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 1,
              style: AppTextStyles.heading3(brightness: Theme.of(context).brightness),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.surfaceDark
                    : AppColors.surfaceLight,
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
              ),
              onChanged: (value) => _onOtpDigitChanged(index, value),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResendOption() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Didn\'t receive code? ',
          style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness),
        ),
        _canResend
            ? TextButton(
                onPressed: _handleResendCode,
                child: Text(
                  'Resend',
                  style: AppTextStyles.buttonMedium(brightness: Theme.of(context).brightness).copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Text(
                'Resend in $_remainingTime seconds',
                style: AppTextStyles.bodySmall(brightness: Theme.of(context).brightness).copyWith(
                  color: AppColors.textSecondary(Theme.of(context).brightness),
                ),
              ),
      ],
    );
  }

  Widget _buildVerifyButton(AuthState state) {
    final isComplete = !_otpValues.contains('');
    
    return AuthButton(
      text: 'Verify',
      isLoading: state.isLoading,
      onPressed: isComplete ? _handleVerifyCode : null,
    );
  }
}
