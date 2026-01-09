import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';


class ValidateResetCodeUseCase {

  final AuthRepository _repository;
  const ValidateResetCodeUseCase(this._repository);

  Future<void> call({required String email, required String code}) async {

    if(email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if(!_isValidEmail(email)) {
      throw Exception('Email is not valid');
    }

    if(code.trim().isEmpty) {
      throw Exception('Code is required');
    }

    if(!_isValidCode(code)) {
      throw Exception('Code must be 6 digits');
    }

    await _repository.validateResetCode(email.trim(), code.trim());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidCode(String code) {
    // Code must be exactly 6 digits
    final codeRegex = RegExp(r'^\d{6}$');
    return codeRegex.hasMatch(code.trim());
  }
}