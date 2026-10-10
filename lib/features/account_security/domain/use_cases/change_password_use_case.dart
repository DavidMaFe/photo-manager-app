import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// Password change with a session (docs/e2ee-spec.md, section 8.4). Every available master key is wrapped again with
/// the KEK of the new password, so the password and the keys change together.
class ChangePasswordUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  ChangePasswordUseCase(this._repository, this._cryptoEngine, this._keyringService);

  Future<void> call({required String currentPassword, required String newPassword}) async {
    AuthInputValidator.requirePassword(currentPassword);
    AuthInputValidator.requireStrongPassword(newPassword);

    final currentParams = await _repository.getKdfParams();
    final currentKeys = await _cryptoEngine.deriveFromPassword(currentPassword, currentParams);
    final newParams = KdfParams(salt: _cryptoEngine.randomBytes(KdfParams.saltLength));
    final newKeys = await _cryptoEngine.deriveFromPassword(newPassword, newParams);
    try {
      final accountKeys = await _repository.getAccountKeys();
      final rewrapped = await _keyringService.rewrapAvailable(accountKeys, newKeys.kek);
      await _repository.changePassword(
        currentAuthKey: currentKeys.authKey,
        newAuthKey: newKeys.authKey,
        kdfParams: newParams,
        keys: rewrapped,
      );
    } finally {
      currentKeys.dispose();
      newKeys.dispose();
    }
  }
}
