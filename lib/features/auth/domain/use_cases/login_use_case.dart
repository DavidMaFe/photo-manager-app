
import 'package:photo_manager_app/features/auth/domain/repositories/auth_repository.dart';
import '../entities/user.dart';


class LoginUseCase {

  final AuthRepository _authRepository;

  LoginUseCase(this._authRepository);

  Future<User> call({required String email, required String password}) async {

    if(email.trim().isEmpty) {
      throw Exception('Email is required');
    }

    if(password.trim().isEmpty) {
      throw Exception('Password is required');
    }

    if(!_isValidEmail(email)) {
      throw Exception('Email is not valid');
    }

    return await _authRepository.login(email: email.trim(), password: password);
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}