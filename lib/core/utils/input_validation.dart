

/// Input validation utility class
/// Contains methods for validating different types of inputs
class InputValidation {
  /// Singleton instance
  static final InputValidation _instance = InputValidation._internal();

  /// Factory constructor
  factory InputValidation() => _instance;

  /// Internal constructor
  InputValidation._internal();

  /// Password requirements
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 64;
  static const bool requireUppercase = true;
  static const bool requireLowercase = true;
  static const bool requireNumbers = true;
  static const bool requireSpecialChars = true;

  /// Regex patterns
  static final RegExp _uppercaseRegex = RegExp(r'[A-Z]');
  static final RegExp _lowercaseRegex = RegExp(r'[a-z]');
  static final RegExp _numberRegex = RegExp(r'[0-9]');
  static final RegExp _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');
  
  /// Sanitization regex for XSS prevention
  static final RegExp _scriptTagRegex = RegExp(r'<script[^>]*>.*?</script>', caseSensitive: false, dotAll: true);
  static final RegExp _eventHandlerRegex = RegExp(r'on\w+\s*=\s*', caseSensitive: false);
  static final RegExp _jsUrlRegex = RegExp(r'javascript:', caseSensitive: false);
  static final RegExp _htmlTagRegex = RegExp(r'<[^>]*>', caseSensitive: false);
  
  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    // Simple email regex
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }
  
  /// Validate phone number
  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    if (digitsOnly.length < 10) {
      return 'Phone number must have at least 10 digits';
    }
    
    return null;
  }
  
  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < minPasswordLength) {
      return 'Password must be at least $minPasswordLength characters';
    }
    
    if (value.length > maxPasswordLength) {
      return 'Password must be less than $maxPasswordLength characters';
    }
    
    if (requireUppercase && !_uppercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    
    if (requireLowercase && !_lowercaseRegex.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    
    if (requireNumbers && !_numberRegex.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    
    if (requireSpecialChars && !_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }
  
  /// Check if password meets all requirements
  Map<String, bool> checkPasswordRequirements(String password) {
    return {
      'length': password.length >= minPasswordLength,
      'uppercase': !requireUppercase || _uppercaseRegex.hasMatch(password),
      'lowercase': !requireLowercase || _lowercaseRegex.hasMatch(password),
      'number': !requireNumbers || _numberRegex.hasMatch(password),
      'special': !requireSpecialChars || _specialCharRegex.hasMatch(password),
    };
  }
  
  /// Sanitize input to prevent XSS attacks
  String sanitizeInput(String input) {
    String sanitized = input;
    
    // Remove script tags
    sanitized = sanitized.replaceAll(_scriptTagRegex, '');
    
    // Remove event handlers
    sanitized = sanitized.replaceAll(_eventHandlerRegex, '');
    
    // Remove javascript: URLs
    sanitized = sanitized.replaceAll(_jsUrlRegex, '');
    
    // Remove HTML tags for text inputs
    sanitized = sanitized.replaceAll(_htmlTagRegex, '');
    
    return sanitized;
  }
  
  /// Validate text input with sanitization
  String? validateTextInput(String? value, {int? maxLength, bool required = true}) {
    if (value == null || value.isEmpty) {
      return required ? 'This field is required' : null;
    }
    
    if (maxLength != null && value.length > maxLength) {
      return 'Input must be less than $maxLength characters';
    }
    
    return null;
  }
  
  /// Validate username
  String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (value.length > 30) {
      return 'Username must be less than 30 characters';
    }
    
    // Only allow alphanumeric characters and underscores
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!usernameRegex.hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }
}
