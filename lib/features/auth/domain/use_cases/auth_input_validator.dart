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

  /// The code of the second factor of a login: the emailed one or one of the authenticator app (6 digits) or, when
  /// [backupCodeAllowed], a backup code (`abcde-fghij`, without regard to case, hyphen or space).
  static void requireSecondFactorCode(String code, {required bool backupCodeAllowed}) {
    final trimmed = code.trim();
    if (RegExp(r'^\d{6}$').hasMatch(trimmed)) return;
    if (backupCodeAllowed && RegExp(r'^[A-Za-z0-9]{5}[- ]?[A-Za-z0-9]{5}$').hasMatch(trimmed)) return;
    throw Exception('Code must be 6 digits');
  }
}
