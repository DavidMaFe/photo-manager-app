import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_outcome.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';


/// Login (docs/e2ee-spec.md, section 8.2): derives authKey and KEK from the password, logs in with the authKey and
/// keeps on this device the master keys it can open with the KEK.
///
/// A device that is not trusted gets no keys yet: the KEK waits in [PendingLogin] until the second factor
/// (VerifyLoginSecondFactorUseCase).
class LoginUseCase {

  final AuthRepository _authRepository;
  final CryptoEngine _cryptoEngine;
  final KeyringService _keyringService;
  final PendingLogin _pendingLogin;

  LoginUseCase(this._authRepository, this._cryptoEngine, this._keyringService, this._pendingLogin);

  Future<LoginOutcome> call({required String email, required String password}) async {

    AuthInputValidator.requireEmail(email);
    AuthInputValidator.requirePassword(password);
    _pendingLogin.clear();

    final normalizedEmail = email.trim();
    final kdfParams = await _authRepository.getKdfParams(normalizedEmail);
    final passwordKeys = await _cryptoEngine.deriveFromPassword(password, kdfParams);
    var keepKeys = false;
    try {
      final outcome = await _authRepository.login(email: normalizedEmail, authKey: passwordKeys.authKey);
      switch (outcome) {
        case LoginCompleted(:final result):
          await _keyringService.unlockAndStore(result.keys, passwordKeys.kek);
        case LoginSecondFactorRequired(:final challenge):
          _pendingLogin.start(challenge, passwordKeys);
          keepKeys = true;
      }
      return outcome;
    } finally {
      if (!keepKeys) {
        passwordKeys.dispose();
      }
    }
  }
}
