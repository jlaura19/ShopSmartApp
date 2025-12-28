// App Constants
class AppConstants {
  // App Info
  static const String appName = 'SmartShop';
  static const String appVersion = '0.0.1';

  // Validation
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 128;
  
  // Email validation regex
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // Password validation - at least one letter and one number
  static final RegExp passwordRegex = RegExp(
    r'^(?=.*[A-Za-z])(?=.*\d).{6,}$',
  );

  // Error Messages
  static const String emailRequiredError = 'Email is required';
  static const String emailInvalidError = 'Please enter a valid email address';
  static const String passwordRequiredError = 'Password is required';
  static const String passwordTooShortError = 'Password must be at least 6 characters';
  static const String passwordWeakError = 'Password must contain at least one letter and one number';
  static const String passwordMismatchError = 'Passwords do not match';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Date Formats
  static const String dateFormat = 'MMM dd, yyyy';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';
}
