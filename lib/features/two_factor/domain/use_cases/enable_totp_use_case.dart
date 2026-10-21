import 'package:photo_manager_app/features/two_factor/domain/repositories/two_factor_repository.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/two_factor_code_validator.dart';

/// Turns the authenticator app on with one of its codes; returns the backup codes, shown once.
class EnableTotpUseCase {
  final TwoFactorRepository _repository;

  EnableTotpUseCase(this._repository);

  Future<List<String>> call(String code) async {
    TwoFactorCodeValidator.requireAppCode(code);
    return _repository.enableTotp(code.trim());
  }
}
