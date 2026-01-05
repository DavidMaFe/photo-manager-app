import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';


class RegisterUseCase {

  final AuthRepository _repository;
  const RegisterUseCase(this._repository);

  Future<void> call({
    required String email,
    required String password,
    required String name, String? surname
  }) async {

    if(email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if(password.trim().isEmpty) {
      throw Exception('Password is required');
    }

    if(!_isValidEmail(email)) {
      throw Exception('Email is not valid');
    }

    if (name.trim().isEmpty) {
      throw Exception('Name is required');
    }

    if (surname != null && surname.trim().isEmpty) {
      surname = null;
    }

    await _repository.register(
        email: email.trim(),
        password: password,
        name: name.trim(),
        surname: surname?.trim()
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}