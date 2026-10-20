import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';

/// Validations shared by the authentication use cases.
class AuthInputValidator {
  const AuthInputValidator._();

  static void requireEmail(String email) {
    if (email.trim().isEmpty) {
      throw Exception('Email is required');
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email.trim())) {
      throw Exception('Email is not valid');
    }
  }

  static void requirePassword(String password) {
    if (password.trim().isEmpty) {
      throw Exception('Password is required');
    }
  }

  /// New passwords need at least [WeakPasswordFailure.minimumLength] characters (decision D6): the server cannot check
  /// it because it never receives the password.
  static void requireStrongPassword(String password) {
    requirePassword(password);
    if (password.length < WeakPasswordFailure.minimumLength) {
      throw const WeakPasswordFailure();
    }
  }

  /// The 6-digit codes sent by email.
  static void requireEmailCode(String code) {
    if (!RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      throw Exception('Code must be 6 digits');
    }
  }
}
