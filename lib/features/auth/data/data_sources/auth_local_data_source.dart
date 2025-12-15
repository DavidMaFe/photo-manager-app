import 'dart:convert';

import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<bool> hasValidToken();
  Future<void> clearCache();
}


class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  final SharedPreferences sharedPreferences;

  static const String _keyUser = 'CACHED_USER';
  static const String _keyToken = 'AUTH_TOKEN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheUser(UserModel user) async {

    final userJson = jsonEncode(user.toJson());
    await sharedPreferences.setString(_keyUser, userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {

    final userJson = sharedPreferences.getString(_keyUser);

    if(userJson != null) {
      final userMap = jsonDecode(userJson);
      return UserModel.fromJson(userMap);
    }

    return null;
  }

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(_keyToken, token);
  }

  @override
  Future<String?> getToken() async{
    return sharedPreferences.getString(_keyToken);
  }

  @override
  Future<bool> hasValidToken() async {

    final token = await getToken();
    return token != null &&  token.isNotEmpty;
  }

  @override
  Future<void> clearCache() async{
    await sharedPreferences.remove(_keyUser);
    await sharedPreferences.remove(_keyToken);
  }
}