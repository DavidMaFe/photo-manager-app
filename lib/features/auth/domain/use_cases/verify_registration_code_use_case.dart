import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// Second step of the registration: checks the emailed code before asking for the rest of the data.
class VerifyRegistrationCodeUseCase {

  final AuthRepository _repository;

  const VerifyRegistrationCodeUseCase(this._repository);

  Future<void> call({required String email, required String code}) async {
    AuthInputValidator.requireEmail(email);
    AuthInputValidator.requireEmailCode(code);
    await _repository.verifyRegistrationCode(email.trim(), code.trim());
  }
}
