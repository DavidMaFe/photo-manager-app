import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/kdf_params.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/auth/domain/entities/registration_result.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';


/// Registration (docs/e2ee-spec.md, section 8.1): the device generates the master key, the recovery key and the
/// identity key pair; the server only receives them wrapped. Returns the 24 words to show to the user.
class RegisterUseCase {

  final AuthRepository _repository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  const RegisterUseCase(this._repository, this._cryptoEngine, this._keyringService);

  Future<RegistrationResult> call({
    required String email,
    required String password,
    required String name,
    String? surname,
    required RecoveryPhraseLanguage language,
  }) async {

    AuthInputValidator.requireEmail(email);
    AuthInputValidator.requireStrongPassword(password);

    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }

    if (surname != null && surname.trim().isEmpty) {
      surname = null;
    }

    final kdfParams = KdfParams(salt: _cryptoEngine.randomBytes(KdfParams.saltLength));
    final passwordKeys = await _cryptoEngine.deriveFromPassword(password, kdfParams);
    try {
      final material = _keyringService.createKeyMaterial(passwordKeys.kek);
      final result = await _repository.register(
          email: email.trim(),
          authKey: passwordKeys.authKey,
          name: name.trim(),
          surname: surname?.trim(),
          kdfParams: kdfParams,
          key: material,
      );

      final version = result.keys.versions.single.version;
      await _keyringService.storeNewKey(version, material);

      return RegistrationResult(
        user: result.user,
        recoveryWords: RecoveryPhrase.encode(material.recoveryKey.bytes, language),
      );
    } finally {
      passwordKeys.dispose();
    }
  }
}
