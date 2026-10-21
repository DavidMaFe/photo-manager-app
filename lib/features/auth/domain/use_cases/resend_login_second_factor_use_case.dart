import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/services/pending_login.dart';

/// Emails another code for the pending login (at most one a minute).
class ResendLoginSecondFactorUseCase {

  final AuthRepository _authRepository;
  final PendingLogin _pendingLogin;

  ResendLoginSecondFactorUseCase(this._authRepository, this._pendingLogin);

  /// Throws [SecondFactorExpiredFailure] when there is no login to go on with.
  Future<void> call() async {
    final challenge = _pendingLogin.challenge;
    if (challenge == null) {
      throw const SecondFactorExpiredFailure();
    }
    try {
      await _authRepository.resendLoginSecondFactor(challenge.challengeToken);
    } catch (e) {
      if (isSecondFactorExpired(e)) {
        _pendingLogin.clear();
      }
      rethrow;
    }
  }
}
