/// What the device offers to keep the secret and the backup codes.
abstract class TwoFactorExporter {
  /// Opens the authenticator app with the secret filled in. False when no app on the device opens the link.
  Future<bool> openInAuthenticator(String otpauthUri);

  /// Shares the backup codes as text (to a password manager, a note...).
  Future<void> shareBackupCodes(String text);
}
