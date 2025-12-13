

import 'package:photo_manager_app/features/auth/data/models/user_model.dart';

abstract class AuthLocalDatasource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<bool> hasValidToken();
  Future<void> clearCache();
}