
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


abstract class AuthRepository {

  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
  Future<void> register({
    required String email,
    required String password,
    required String name,
    String? surname
  });
  Future<bool> hasToken();
  Future<void> refreshToken();

  // Password Reset
  Future<void> requestPasswordReset(String email);
  Future<void> validateResetCode(String email, String code);
  Future<void> resetPassword(String email, String code, String newPassword);
}