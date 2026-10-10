import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


/// Authentication without sending the password: the server only receives the authKey derived from it
/// (docs/e2ee-spec.md, section 8).
abstract class AuthRepository {

  /// Salt and Argon2id parameters of the password of [email] (a stable fake answer for unknown emails).
  Future<KdfParams> getKdfParams(String email);
  Future<LoginResult> login({required String email, required CryptoKey authKey});

  /// Logs out and removes the tokens and the keys of this device.
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<LoginResult> register({
    required String email,
    required CryptoKey authKey,
    required String name,
    String? surname,
    required KdfParams kdfParams,
    required NewKeyMaterial key,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
  });
  Future<bool> hasToken();
  Future<void> refreshToken();

  // Password Reset
  Future<void> requestPasswordReset(String email);
  Future<void> validateResetCode(String email, String code);

  /// Master keys wrapped with the recovery key, given with a valid emailed code.
  Future<List<RecoveryWrap>> getRecoveryWraps(String email, String code);

  /// Returns whether the account is locked after the reset.
  Future<bool> resetPassword({
    required String email,
    required String code,
    required CryptoKey newAuthKey,
    required KdfParams kdfParams,
    required List<RecoveredKey> recoveredKeys,
  });
}
