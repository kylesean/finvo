import 'package:finvo/i18n/strings.g.dart';

/// Centralized validators for authentication fields (email, phone, password).
class AuthValidators {
  static final RegExp _phoneRegex = RegExp(r'^1[3-9]\d{9}$');
  static final RegExp _emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

  /// Check whether an input string is a valid China mobile phone number.
  static bool isPhone(String value) => _phoneRegex.hasMatch(value);

  /// Check whether an input string is a valid email address.
  static bool isEmail(String value) => _emailRegex.hasMatch(value);

  /// Validate a contact input (either email or mobile phone).
  static String? validateContact(String? value) {
    if (value == null || value.trim().isEmpty) {
      return t.auth.email.required;
    }
    final trimmed = value.trim();
    if (!isPhone(trimmed) && !isEmail(trimmed)) {
      return t.auth.email.invalid;
    }
    return null;
  }
}
