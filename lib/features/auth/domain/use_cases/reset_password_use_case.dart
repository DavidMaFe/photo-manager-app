import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';


/// Forgotten password with the emailed code (docs/e2ee-spec.md, section 8.5).
///
/// With the 24 words, the key versions they open keep working with the new password. Without them the password
/// changes but the account becomes locked: the photos are kept, never deleted, and can be unlocked later.
/// Returns whether the account is locked.
class ResetPasswordUseCase {

  final AuthRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  const ResetPasswordUseCase(this._repository, this._cryptoEngine, this._keyringService);

  Future<bool> call({
    required String email,
    required String code,
    required String newPassword,
    List<String>? recoveryWords,
  }) async {

    AuthInputValidator.requireEmail(email);

    if(code.trim().isEmpty) {
      throw Exception('Code is required');
    }

    if(!RegExp(r'^\d{6}$').hasMatch(code.trim())) {
      throw Exception('Code must be 6 digits');
    }

    AuthInputValidator.requireStrongPassword(newPassword);

    final normalizedEmail = email.trim();
    final normalizedCode = code.trim();

    // Checked before asking the server, so a typo in the words is detected at once
    final recoveryKey = recoveryWords == null ? null : _keyringService.recoveryKeyFromWords(recoveryWords);

    final kdfParams = KdfParams(salt: _cryptoEngine.randomBytes(KdfParams.saltLength));
    final passwordKeys = await _cryptoEngine.deriveFromPassword(newPassword, kdfParams);
    try {
      var recovered = <RecoveredKey>[];
      if (recoveryKey != null) {
        final wraps = await _repository.getRecoveryWraps(normalizedEmail, normalizedCode);
        recovered = _keyringService.recover(wraps, recoveryKey, passwordKeys.kek);
      }

      return await _repository.resetPassword(
        email: normalizedEmail,
        code: normalizedCode,
        newAuthKey: passwordKeys.authKey,
        kdfParams: kdfParams,
        recoveredKeys: recovered,
      );
    } finally {
      passwordKeys.dispose();
      recoveryKey?.dispose();
    }
  }
}
