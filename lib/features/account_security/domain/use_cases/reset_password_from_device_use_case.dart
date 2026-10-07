import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/account_security/domain/services/device_authenticator.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// "I forgot my password" on a device with an open session (docs/e2ee-spec.md, section 8.5): after the device lock,
/// the keys this device holds are wrapped with the new password and the server gets the proof that the device has them.
class ResetPasswordFromDeviceUseCase {
  final AccountSecurityRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;
  final DeviceAuthenticator _deviceAuthenticator;

  ResetPasswordFromDeviceUseCase(this._repository, this._cryptoEngine, this._keyringService, this._deviceAuthenticator);

  /// [reason] is the translated text the system shows with the fingerprint or PIN prompt.
  Future<void> call({required String newPassword, required String reason}) async {
    AuthInputValidator.requireStrongPassword(newPassword);

    if (!await _deviceAuthenticator.isAvailable() || !await _deviceAuthenticator.authenticate(reason)) {
      throw const DeviceAuthenticationFailure();
    }

    final newParams = KdfParams(salt: _cryptoEngine.randomBytes(KdfParams.saltLength));
    final newKeys = await _cryptoEngine.deriveFromPassword(newPassword, newParams);
    try {
      final accountKeys = await _repository.getAccountKeys();
      final rewrapped = await _keyringService.rewrapWithDeviceProof(accountKeys, newKeys.kek);
      await _repository.resetPasswordFromDevice(newAuthKey: newKeys.authKey, kdfParams: newParams, keys: rewrapped);
    } finally {
      newKeys.dispose();
    }
  }
}
