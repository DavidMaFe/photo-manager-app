import 'dart:convert';

import 'package:photo_manager_app/core/storage/secure_store.dart';
import 'package:photo_manager_app/features/auth/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> cacheToken(String token);
  Future<String?> getToken();
  Future<void> cacheRefreshToken(String refreshToken);
  Future<String?> getRefreshToken();
  Future<void> cacheLoginTimestamp(DateTime timestamp);
  Future<DateTime?> getLoginTimestamp();
  Future<bool> hasValidToken();
  Future<void> clearCache();
}


/// The tokens live in the secure storage (Keystore/Keychain); the cached user and the login time, which are not
/// secrets, stay in SharedPreferences.
class AuthLocalDataSourceImpl implements AuthLocalDataSource {

  final SharedPreferences sharedPreferences;
  final SecureStore secureStore;

  static const String _keyUser = 'CACHED_USER';
  static const String _keyToken = 'AUTH_TOKEN';
  static const String _keyRefreshToken = 'REFRESH_TOKEN';
  static const String _keyLoginTimestamp = 'LOGIN_TIMESTAMP';

  AuthLocalDataSourceImpl({required this.sharedPreferences, required this.secureStore});

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
    await secureStore.write(_keyToken, token);
    await _removeLegacyTokens();
  }

  @override
  Future<String?> getToken() async{
    return secureStore.read(_keyToken);
  }

  @override
  Future<void> cacheRefreshToken(String refreshToken) async {
    await secureStore.write(_keyRefreshToken, refreshToken);
    await _removeLegacyTokens();
  }

  @override
  Future<String?> getRefreshToken() async {
    return secureStore.read(_keyRefreshToken);
  }

  @override
  Future<void> cacheLoginTimestamp(DateTime timestamp) async {
    await sharedPreferences.setString(_keyLoginTimestamp, timestamp.toIso8601String());
  }

  @override
  Future<DateTime?> getLoginTimestamp() async {
    final timestampString = sharedPreferences.getString(_keyLoginTimestamp);
    if (timestampString != null) {
      return DateTime.parse(timestampString);
    }
    return null;
  }

  @override
  Future<bool> hasValidToken() async {

    final token = await getToken();
    return token != null &&  token.isNotEmpty;
  }

  @override
  Future<void> clearCache() async{
    await sharedPreferences.remove(_keyUser);
    await sharedPreferences.remove(_keyLoginTimestamp);
    await secureStore.delete(_keyToken);
    await secureStore.delete(_keyRefreshToken);
    await _removeLegacyTokens();
  }

  /// Versions before the end-to-end encryption kept the tokens in SharedPreferences, unencrypted.
  Future<void> _removeLegacyTokens() async {
    await sharedPreferences.remove(_keyToken);
    await sharedPreferences.remove(_keyRefreshToken);
  }
}