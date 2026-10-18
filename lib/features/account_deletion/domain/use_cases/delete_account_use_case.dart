import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/features/account_deletion/domain/repositories/account_deletion_repository.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// Deletes the account for good (ROADMAP-downloads-and-account-deletion.md, Phase 5; docs/e2ee-spec.md, section 8.8).
///
/// The password is checked by the server through its authKey, derived as in the login. Once the server deleted the
/// account, [onDeleted] removes everything this device keeps for it: the session and the keys, the caches, the file
/// mappings, the downloads, the sync configuration and the background tasks. A failed cleanup does not stop the
/// others: the account no longer exists.
class DeleteAccountUseCase {
  final AccountDeletionRepository _repository;
  final AccountSecurityRepository _accountSecurityRepository;
  final CryptoEngine _cryptoEngine;
  final List<Future<void> Function()> _onDeleted;

  DeleteAccountUseCase(this._repository, this._accountSecurityRepository, this._cryptoEngine,
      {List<Future<void> Function()> onDeleted = const []})
      : _onDeleted = onDeleted;

  Future<void> call({required String password}) async {
    AuthInputValidator.requirePassword(password);

    final params = await _accountSecurityRepository.getKdfParams();
    final keys = await _cryptoEngine.deriveFromPassword(password, params);
    try {
      await _repository.deleteAccount(keys.authKey);
    } finally {
      keys.dispose();
    }

    for (final cleanup in _onDeleted) {
      try {
        await cleanup();
      } catch (_) {
        // The account is already deleted: the other cleanups must still run
      }
    }
  }
}
