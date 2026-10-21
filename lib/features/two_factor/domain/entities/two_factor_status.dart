/// The second factor of the account: with the authenticator app on ([totpEnabled]), the logins from a new device ask
/// for its codes (or a backup code) instead of an emailed one.
class TwoFactorStatus {
  final bool totpEnabled;
  final int backupCodesLeft;

  const TwoFactorStatus({required this.totpEnabled, required this.backupCodesLeft});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwoFactorStatus && other.totpEnabled == totpEnabled && other.backupCodesLeft == backupCodesLeft;

  @override
  int get hashCode => Object.hash(totpEnabled, backupCodesLeft);
}
