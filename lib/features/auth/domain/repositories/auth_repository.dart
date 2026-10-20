import 'package:photo_manager_app/core/crypto/domain/crypto_key.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_outcome.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


/// Authentication without sending the password: the server only receives the authKey derived from it
/// (docs/e2ee-spec.md, section 8).
abstract class AuthRepository {

  /// Salt and Argon2id parameters of the password of [email] (a stable fake answer for unknown emails).
  Future<KdfParams> getKdfParams(String email);

  /// A trusted device gets the session ([LoginCompleted]); any other one, a second factor ([LoginSecondFactorRequired]).
  Future<LoginOutcome> login({required String email, required CryptoKey authKey});

  /// Passes the second factor with the emailed [code]: the session starts and this device is trusted from now on.
  Future<LoginResult> verifyLoginSecondFactor({required String challengeToken, required String code});

  /// Emails another code for the login of [challengeToken].
  Future<void> resendLoginSecondFactor(String challengeToken);

  /// Logs out and removes the tokens and the keys of this device.
  Future<void> logout();

  /// Removes the tokens, the cached user and the keys of this device without calling the server (the account was
  /// deleted, so its tokens are no longer valid).
  Future<void> clearSession();
  Future<User?> getCurrentUser();

  /// First step of the registration: emails a code to verify [email]. Fails with an `EmailAlreadyExistsFailure` when
  /// the email already has an account.
  Future<void> requestRegistrationCode(String email);

  /// Second step: checks the emailed code without spending it (the registration spends it).
  Future<void> verifyRegistrationCode(String email, String code);

  /// [emailCode] is the code emailed by [requestRegistrationCode].
  Future<LoginResult> register({
    required String email,
    required CryptoKey authKey,
    required String name,
    String? surname,
    required KdfParams kdfParams,
    required NewKeyMaterial key,
    required String acceptedTermsVersion,
    required String acceptedPrivacyVersion,
    required String emailCode,
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
