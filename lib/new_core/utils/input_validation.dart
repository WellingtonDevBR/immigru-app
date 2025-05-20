/// Utility class for input validation
class InputValidation {
  /// Validates an email address
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    
    final emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegExp.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    
    return null;
  }

  /// Validates a password
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    
    // Check for at least one uppercase letter
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    
    // Check for at least one number
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    
    // Check for at least one special character
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain at least one special character';
    }
    
    return null;
  }

  /// Validates a phone number
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    
    // Remove any non-digit characters for validation
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
    
    // Check if the phone number has a reasonable length
    if (digitsOnly.length < 8 || digitsOnly.length > 15) {
      return 'Enter a valid phone number';
    }
    
    return null;
  }

  /// Validates a name
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    
    return null;
  }

  /// Validates a username
  static String? validateUsername(String? value) {
    if (value == null || value.isEmpty) {
      return 'Username is required';
    }
    
    if (value.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    // Username should only contain letters, numbers, and underscores
    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  /// Validates a verification code (OTP)
  static String? validateVerificationCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Verification code is required';
    }
    
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Verification code must contain only digits';
    }
    
    if (value.length != 6) {
      return 'Verification code must be 6 digits';
    }
    
    return null;
  }
  
  /// Validates general text input
  static String? validateTextInput(String? value, {int? maxLength, bool required = true}) {
    if (required && (value == null || value.isEmpty)) {
      return 'This field is required';
    }
    
    if (maxLength != null && value != null && value.length > maxLength) {
      return 'Input exceeds maximum length of $maxLength characters';
    }
    
    return null;
  }
  
  /// Sanitizes input by removing unwanted characters
  static String sanitizeInput(String value) {
    // Remove leading/trailing whitespace
    String sanitized = value.trim();
    
    // Remove any control characters
    sanitized = sanitized.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');
    
    // Replace multiple spaces with a single space
    sanitized = sanitized.replaceAll(RegExp(r'\s+'), ' ');
    
    return sanitized;
  }
}
