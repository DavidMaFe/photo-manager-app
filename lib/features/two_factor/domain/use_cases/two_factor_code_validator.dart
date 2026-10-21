/// The codes of the second factor: 6 digits of the authenticator app, or a backup code (`abcde-fghij`, without
/// regard to case, hyphen or space).
class TwoFactorCodeValidator {
  const TwoFactorCodeValidator._();

  static final _appCode = RegExp(r'^\d{6}$');
  static final _backupCode = RegExp(r'^[A-Za-z0-9]{5}[- ]?[A-Za-z0-9]{5}$');

  static bool isAppCode(String code) => _appCode.hasMatch(code.trim());

  static bool isBackupCode(String code) => _backupCode.hasMatch(code.trim());

  static void requireAppCode(String code) {
    if (!isAppCode(code)) {
      throw Exception('Code must be 6 digits');
    }
  }

  static void requireAppOrBackupCode(String code) {
    if (!isAppCode(code) && !isBackupCode(code)) {
      throw Exception('Code must be 6 digits or a backup code');
    }
  }
}
