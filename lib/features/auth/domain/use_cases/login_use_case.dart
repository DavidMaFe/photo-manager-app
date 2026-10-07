import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';


/// Login (docs/e2ee-spec.md, section 8.2): derives authKey and KEK from the password, logs in with the authKey and
/// keeps on this device the master keys it can open with the KEK.
class LoginUseCase {

  final AuthRepository _authRepository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;

  LoginUseCase(this._authRepository, this._cryptoEngine, this._keyringService);

  Future<LoginResult> call({required String email, required String password}) async {

    AuthInputValidator.requireEmail(email);
    AuthInputValidator.requirePassword(password);

    final normalizedEmail = email.trim();
    final kdfParams = await _authRepository.getKdfParams(normalizedEmail);
    final passwordKeys = await _cryptoEngine.deriveFromPassword(password, kdfParams);
    try {
      final result = await _authRepository.login(email: normalizedEmail, authKey: passwordKeys.authKey);
      await _keyringService.unlockAndStore(result.keys, passwordKeys.kek);
      return result;
    } finally {
      passwordKeys.dispose();
    }
  }
}
