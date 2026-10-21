import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/auth_input_validator.dart';

/// First step of the registration: emails a code that verifies the email. An email that already has an account fails
/// at once, before the user fills the rest of the registration.
class RequestRegistrationCodeUseCase {

  final AuthRepository _repository;

  const RequestRegistrationCodeUseCase(this._repository);

  Future<void> call(String email) async {
    AuthInputValidator.requireEmail(email);
    await _repository.requestRegistrationCode(email.trim());
  }
}
