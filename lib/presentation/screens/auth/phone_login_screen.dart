import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:immigru/core/di/injection_container.dart';
import 'package:immigru/presentation/blocs/auth/auth_bloc.dart';
import 'package:immigru/presentation/blocs/auth/auth_event.dart';
import 'package:immigru/presentation/blocs/auth/auth_state.dart';
import 'package:immigru/presentation/screens/home/home_screen.dart';
import 'package:flutter/services.dart';
import 'package:immigru/presentation/theme/app_colors.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({super.key});

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isSubmitting = false;
  String _completePhoneNumber = '';
  String _initialCountryCode = 'US'; // Default country code

  @override
  void initState() {
    super.initState();

    // Delay execution until context is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locale = View.of(context).platformDispatcher.locale.countryCode;
      if (locale != null && locale.isNotEmpty) {
        setState(() {
          _initialCountryCode = locale;
        });
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _sendOtp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Use the complete phone number with country code
      final phone = _completePhoneNumber.isNotEmpty
          ? _completePhoneNumber
          : _phoneController.text.trim();

      context.read<AuthBloc>().add(AuthSendOtpEvent(phone: phone));
    }
  }

  void _verifyOtp(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Use the complete phone number with country code
      final phone = _completePhoneNumber.isNotEmpty
          ? _completePhoneNumber
          : _phoneController.text.trim();
      final otpCode = _otpController.text.trim();

      // Verify OTP with Supabase and sign in
      context.read<AuthBloc>().add(
            AuthPhoneLoginEvent(
              phone: phone,
              otpCode: otpCode,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    final primaryColor = AppColors.primaryColor;

    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        backgroundColor: isDarkMode ? AppColors.darkBackground : Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Phone Login',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() {
              _isSubmitting = false;
            });

            if (state.hasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'An error occurred'),
                  backgroundColor: Colors.red,
                ),
              );
            }

            if (state.isOtpSent) {
              setState(() {
                _otpSent = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('OTP sent to your phone'),
                  backgroundColor: Colors.green,
                ),
              );
            }

            if (state.isAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          },
          builder: (context, state) {
            return SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = MediaQuery.of(context).size;
                  final isSmallScreen = size.width < 600;
                  final isLandscape = size.width > size.height;

                  return Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 24 : size.width * 0.1,
                        vertical: isSmallScreen ? 16 : size.height * 0.05,
                      ),
                      child: Container(
                        width: isSmallScreen ? null : 450,
                        constraints: BoxConstraints(
                          minHeight: isLandscape
                              ? size.height * 0.8
                              : size.height * 0.5,
                          maxWidth: 450,
                        ),
                        decoration: BoxDecoration(
                          color:
                              isDarkMode ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: isDarkMode
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                        ),
                        padding: EdgeInsets.all(isSmallScreen ? 24 : 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Phone icon
                              Align(
                                alignment: Alignment.center,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: primaryColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding: const EdgeInsets.all(12),
                                  child: Icon(
                                    Icons.phone_android,
                                    color: primaryColor,
                                    size: 28,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Title
                              Text(
                                _otpSent ? 'Verify OTP' : 'Phone Login',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _otpSent
                                    ? 'Enter the verification code sent to your phone'
                                    : 'We\'ll send a verification code to your phone',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),

                              // Phone Field
                              if (!_otpSent || isLandscape) ...[
                                Text(
                                  'Phone Number',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                IntlPhoneField(
                                  controller: _phoneController,
                                  enabled: !_otpSent || isLandscape,
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  dropdownTextStyle: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                  dropdownIcon: Icon(
                                    Icons.arrow_drop_down,
                                    color: isDarkMode
                                        ? Colors.white70
                                        : Colors.black54,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your phone number',
                                    hintStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white54
                                          : Colors.black38,
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.grey.withValues(alpha: 0.1)
                                        : Colors.grey.withValues(alpha: 0.05),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode
                                            ? Colors.white30
                                            : Colors.black12,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: isDarkMode
                                            ? Colors.white30
                                            : Colors.black12,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                  initialCountryCode: _initialCountryCode,
                                  onChanged: (phone) {
                                    setState(() {
                                      _completePhoneNumber =
                                          phone.completeNumber;
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
                                const SizedBox(height: 16),
                              ],

                              // OTP Field
                              if (_otpSent || isLandscape) ...[
                                Text(
                                  'Verification Code',
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                      letterSpacing: 12,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: '• • • • • •',
                                      hintStyle: TextStyle(
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black38,
                                        letterSpacing: 12,
                                        fontSize: 22,
                                      ),
                                      filled: true,
                                      fillColor: isDarkMode
                                          ? Colors.grey.withValues(alpha: 0.1)
                                          : Colors.grey.withValues(alpha: 0.05),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: primaryColor.withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: primaryColor.withValues(alpha: 0.3),
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(16),
                                        borderSide: BorderSide(
                                          color: primaryColor,
                                          width: 2,
                                        ),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 24),
                                      prefixIcon: Icon(
                                        Icons.lock_outline,
                                        color: isDarkMode
                                            ? Colors.white54
                                            : Colors.black38,
                                        size: 22,
                                      ),
                                    ),
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(6),
                                    ],
                                    validator: _otpSent
                                        ? (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Please enter the verification code';
                                            }
                                            if (value.length < 6) {
                                              return 'Please enter a valid verification code';
                                            }
                                            return null;
                                          }
                                        : null,
                                  ),
                                ),

                                // OTP instructions
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  child: Text(
                                    'Enter the 6-digit code sent to your phone number',
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 14,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],

                              // Resend OTP
                              if (_otpSent)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _sendOtp(context),
                                    style: TextButton.styleFrom(
                                      foregroundColor: primaryColor,
                                      padding: EdgeInsets.zero,
                                      minimumSize: const Size(0, 0),
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Resend Code',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 24),

                              // Action Button
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: _isSubmitting
                                      ? null
                                      : () => _otpSent
                                          ? _verifyOtp(context)
                                          : _sendOtp(context),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    elevation: 0,
                                    disabledBackgroundColor:
                                        primaryColor.withValues(alpha: 0.6),
                                  ),
                                  child: _isSubmitting
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    Colors.white),
                                          ),
                                        )
                                      : Text(
                                          _otpSent
                                              ? 'Verify & Login'
                                              : 'Send Verification Code',
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
