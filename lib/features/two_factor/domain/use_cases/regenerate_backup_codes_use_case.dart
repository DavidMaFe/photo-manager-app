import 'package:photo_manager_app/core/crypto/domain/crypto_engine.dart';
import 'package:photo_manager_app/features/account_security/domain/repositories/account_security_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';
import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/two_factor_code_validator.dart';

/// New backup codes, with the password and a code of the app (or a backup code); the previous ones stop working.
class RegenerateBackupCodesUseCase {
  final TwoFactorRepository _repository;
  final AccountSecurityRepository _accountSecurityRepository;
  final CryptoEngine _cryptoEngine;

  RegenerateBackupCodesUseCase(this._repository, this._accountSecurityRepository, this._cryptoEngine);

  Future<List<String>> call({required String password, required String code}) async {
    AuthInputValidator.requirePassword(password);
    TwoFactorCodeValidator.requireAppOrBackupCode(code);

    final keys = await _cryptoEngine.deriveFromPassword(password, await _accountSecurityRepository.getKdfParams());
    try {
      return await _repository.regenerateBackupCodes(authKey: keys.authKey, code: code.trim());
    } finally {
      keys.dispose();
    }
  }
}
