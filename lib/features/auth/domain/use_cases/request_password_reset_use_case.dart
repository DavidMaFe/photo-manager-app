import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';


class RequestPasswordResetUseCase {

  final AuthRepository _repository;
  const RequestPasswordResetUseCase(this._repository);

  Future<void> call({required String email}) async {

    if(email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if(!_isValidEmail(email)) {
      throw Exception('Email is not valid');
    }

    await _repository.requestPasswordReset(email.trim());
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}