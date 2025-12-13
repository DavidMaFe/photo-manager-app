
import 'package:photo_manager_app/features/auth/domain/entities/user.dart';


abstract class AuthRepository {

  Future<User> login({required String email, required String password});
  Future<void> logout();
  Future<User?> getCurrentUser();
  //Future<User> register({required String email, required String password,
    //required String name, String? surname});
  Future<bool> hasToken();
}