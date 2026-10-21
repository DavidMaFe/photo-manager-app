import 'package:photo_manager_app/core/crypto/domain/keyring_service.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/domain/entities/login_result.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// Second step of a login from a device that is not trusted: sends the emailed code, and with the answer keeps the
/// master keys it can open with the KEK of the pending login. A wrong code keeps the login pending; an expired one
/// ends it.
class VerifyLoginSecondFactorUseCase {

  final AuthRepository _authRepository;
  final KeyringService _keyringService;
  final PendingLogin _pendingLogin;

  VerifyLoginSecondFactorUseCase(this._authRepository, this._keyringService, this._pendingLogin);

  /// [code]: the emailed one or, with the authenticator app, one of its codes or a backup code.
  ///
  /// Throws [SecondFactorExpiredFailure] when there is no login to go on with.
  Future<LoginResult> call(String code) async {
    final challenge = _pendingLogin.challenge;
    final keys = _pendingLogin.keys;
    if (challenge == null || keys == null) {
      throw const SecondFactorExpiredFailure();
    }
    AuthInputValidator.requireSecondFactorCode(code, backupCodeAllowed: challenge.usesAuthenticatorApp);

    try {
      final result = await _authRepository.verifyLoginSecondFactor(
          challengeToken: challenge.challengeToken, code: code.trim());
      await _keyringService.unlockAndStore(result.keys, keys.kek);
      _pendingLogin.clear();
      return result;
    } catch (e) {
      if (isSecondFactorExpired(e)) {
        _pendingLogin.clear();
      }
      rethrow;
    }
  }
}
