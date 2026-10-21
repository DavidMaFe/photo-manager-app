import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/two_factor_code_validator.dart';

/// Turns the authenticator app off. The server checks the password through its authKey, derived as in the login, and
/// a code of the app or a backup code: a stolen session is not enough.
class DisableTotpUseCase {
  final TwoFactorRepository _repository;
  final AccountSecurityRepository _accountSecurityRepository;
  final CryptoEngine _cryptoEngine;

  DisableTotpUseCase(this._repository, this._accountSecurityRepository, this._cryptoEngine);

  Future<void> call({required String password, required String code}) async {
    AuthInputValidator.requirePassword(password);
    TwoFactorCodeValidator.requireAppOrBackupCode(code);

    final keys = await _cryptoEngine.deriveFromPassword(password, await _accountSecurityRepository.getKdfParams());
    try {
      await _repository.disableTotp(authKey: keys.authKey, code: code.trim());
    } finally {
      keys.dispose();
    }
  }
}
