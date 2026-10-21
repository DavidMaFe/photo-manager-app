import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';

/// The authenticator app and the backup codes of the account (/api/auth/2fa/).
abstract class TwoFactorRepository {
  Future<TwoFactorStatus> getStatus();

  /// A new secret, pending until [enableTotp].
  Future<TotpSetUp> setUpTotp();

  /// Turns the app on with one of its codes. Returns the backup codes, shown once.
  Future<List<String>> enableTotp(String code);

  /// [code]: of the app, or a backup code.
  Future<void> disableTotp({required CryptoKey authKey, required String code});

  /// Returns the new backup codes; the previous ones stop working.
  Future<List<String>> regenerateBackupCodes({required CryptoKey authKey, required String code});
}
