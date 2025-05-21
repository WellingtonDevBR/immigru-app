import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:immigru/features/auth/presentation/widgets/password_requirements_widget.dart';
import 'package:immigru/core/utils/input_validation.dart';
import 'package:immigru/shared/theme/app_text_styles.dart';

/// Type of input field
enum SecureInputType {
  /// Password input
  password,
  
  /// Text input
  text,
  
  /// Email input
  email,
  
  /// Phone input
  phone,
  
  /// Username input
  username,
  
  /// Bio or long text input
  bio
}

/// A secure input field widget with built-in validation and sanitization
class SecureInputField extends StatefulWidget {
  /// Controller for the input field
  final TextEditingController controller;
  
  /// Focus node for the input field
  final FocusNode? focusNode;
  
  /// Label text for the input field
  final String labelText;
  
  /// Hint text for the input field
  final String? hintText;
  
  /// Helper text for the input field
  final String? helperText;
  
  /// Error text for the input field
  final String? errorText;
  
  /// Type of input field
  final SecureInputType inputType;
  
  /// Whether to show the password requirements (only for password type)
  final bool showPasswordRequirements;
  
  /// Whether the field is required
  final bool isRequired;
  
  /// Maximum length of the input
  final int? maxLength;
  
  /// Maximum lines for the input (for multiline inputs)
  final int? maxLines;
  
  /// Minimum lines for the input (for multiline inputs)
  final int? minLines;
  
  /// Callback when the input changes
  final ValueChanged<String>? onChanged;
  
  /// Callback when the input is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Callback for custom validation
  final String? Function(String?)? validator;
  
  /// Input formatters for the field
  final List<TextInputFormatter>? inputFormatters;
  
  /// Whether the field is enabled
  final bool enabled;
  
  /// Whether to auto-validate the input
  final bool autoValidate;
  
  /// Whether to show the clear button
  final bool showClearButton;
  
  /// Constructor
  const SecureInputField({
    super.key,
    required this.controller,
    this.focusNode,
    required this.labelText,
    this.hintText,
    this.helperText,
    this.errorText,
    this.inputType = SecureInputType.text,
    this.showPasswordRequirements = true,
    this.isRequired = true,
    this.maxLength,
    this.maxLines,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
    this.validator,
    this.inputFormatters,
    this.enabled = true,
    this.autoValidate = false,
    this.showClearButton = true,
  });

  @override
  State<SecureInputField> createState() => _SecureInputFieldState();
}

class _SecureInputFieldState extends State<SecureInputField> {
  bool _obscureText = true;
  bool _isFocused = false;
  String? _errorText;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize obscureText based on input type
    _obscureText = widget.inputType == SecureInputType.password;
    
    // Add listener to focus node
    widget.focusNode?.addListener(_handleFocusChange);
  }
  
  @override
  void dispose() {
    // Remove listener from focus node
    widget.focusNode?.removeListener(_handleFocusChange);
    super.dispose();
  }
  
  /// Handle focus change
  void _handleFocusChange() {
    setState(() {
      _isFocused = widget.focusNode?.hasFocus ?? false;
      
      // Validate on focus lost if autoValidate is enabled
      if (widget.autoValidate && !_isFocused) {
        _validate(widget.controller.text);
      }
    });
  }
  
  /// Validate the input
  String? _validate(String? value) {
    // Use custom validator if provided
    if (widget.validator != null) {
      final customError = widget.validator!(value);
      if (customError != null) {
        setState(() => _errorText = customError);
        return customError;
      }
    }
    
    // Use built-in validators based on input type
    String? error;
    switch (widget.inputType) {
      case SecureInputType.password:
        error = InputValidation.validatePassword(value);
        break;
      case SecureInputType.email:
        error = InputValidation.validateEmail(value);
        break;
      case SecureInputType.phone:
        error = InputValidation.validatePhoneNumber(value);
        break;
      case SecureInputType.username:
        error = InputValidation.validateUsername(value);
        break;
      case SecureInputType.text:
      case SecureInputType.bio:
        error = InputValidation.validateTextInput(
          value, 
          maxLength: widget.maxLength,
          required: widget.isRequired,
        );
        break;
    }
    
    setState(() => _errorText = error);
    return error;
  }
  
  /// Handle text change
  void _handleTextChange(String value) {
    // Sanitize input
    final sanitized = InputValidation.sanitizeInput(value);
    
    // Only update if the sanitized value is different
    if (sanitized != value) {
      widget.controller.text = sanitized;
      widget.controller.selection = TextSelection.fromPosition(
        TextPosition(offset: sanitized.length),
      );
    }
    
    // Validate if autoValidate is enabled
    if (widget.autoValidate) {
      _validate(sanitized);
    }
    
    // Call onChanged callback
    widget.onChanged?.call(sanitized);
    
    // Force rebuild for password requirements
    if (widget.inputType == SecureInputType.password) {
      setState(() {});
    }
  }
  
  /// Clear the input
  void _clearInput() {
    widget.controller.clear();
    setState(() => _errorText = null);
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDarkMode = brightness == Brightness.dark;
    
    // Determine keyboard type based on input type
    TextInputType keyboardType;
    switch (widget.inputType) {
      case SecureInputType.email:
        keyboardType = TextInputType.emailAddress;
        break;
      case SecureInputType.phone:
        keyboardType = TextInputType.phone;
        break;
      case SecureInputType.bio:
        keyboardType = TextInputType.multiline;
        break;
      default:
        keyboardType = TextInputType.text;
        break;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text field
        TextFormField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          obscureText: widget.inputType == SecureInputType.password && _obscureText,
          keyboardType: keyboardType,
          maxLength: widget.maxLength,
          maxLines: widget.inputType == SecureInputType.bio || widget.inputType == SecureInputType.text 
              ? widget.maxLines ?? (widget.inputType == SecureInputType.bio ? 5 : 1)
              : 1,
          minLines: widget.inputType == SecureInputType.bio ? widget.minLines ?? 3 : null,
          enabled: widget.enabled,
          inputFormatters: widget.inputFormatters,
          style: AppTextStyles.bodyMedium(brightness: brightness),
          decoration: InputDecoration(
            labelText: widget.labelText,
            hintText: widget.hintText,
            helperText: widget.helperText,
            errorText: widget.errorText ?? _errorText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2.0,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: isDarkMode ? Colors.red.shade300 : Colors.red,
                width: 2.0,
              ),
            ),
            suffixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Show clear button if text is not empty and showClearButton is true
                if (widget.controller.text.isNotEmpty && widget.showClearButton)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 20),
                    onPressed: _clearInput,
                    splashRadius: 20,
                  ),
                
                // Show visibility toggle for password fields
                if (widget.inputType == SecureInputType.password)
                  IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                    splashRadius: 20,
                  ),
              ],
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
          onChanged: _handleTextChange,
          onFieldSubmitted: widget.onSubmitted,
          validator: _validate,
        ),
        
        // Password requirements widget
        if (widget.inputType == SecureInputType.password && 
            widget.showPasswordRequirements &&
            (widget.controller.text.isNotEmpty || _isFocused))
          PasswordRequirementsWidget(
            password: widget.controller.text,
            visible: true,
          ),
      ],
    );
  }
}
