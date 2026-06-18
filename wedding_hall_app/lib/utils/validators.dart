class Validators {
  /// Validate email format
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate phone number (10 digits)
  static bool isValidPhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }
    final phoneRegex = RegExp(r'^\d{10}$');
    return phoneRegex.hasMatch(phone.replaceAll(RegExp(r'\D'), ''));
  }

  /// Validate password
  static bool isValidPassword(String? password) {
    if (password == null || password.isEmpty) {
      return false;
    }
    return password.length >= 6;
  }

  /// Validate name
  static bool isValidName(String? name) {
    if (name == null || name.isEmpty) {
      return false;
    }
    return name.length >= 2;
  }

  /// Get email error message
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!isValidEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Get phone error message
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (!isValidPhone(value)) {
      return 'Please enter a valid 10-digit phone';
    }
    return null;
  }

  /// Get password error message
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (!isValidPassword(value)) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Get name error message
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (!isValidName(value)) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }
}
