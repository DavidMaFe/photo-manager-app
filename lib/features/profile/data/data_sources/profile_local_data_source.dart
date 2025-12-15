import 'dart:convert';

import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class ProfileLocalDataSource {
  Future<void> cacheProfile(UserProfileModel profile);
  Future<UserProfileModel?> getCachedProfile();
  Future<void> clearProfileCache();
}


class ProfileLocalDataSourceImpl implements ProfileLocalDataSource {

  final SharedPreferences sharedPreferences;
  static const String _keyProfile = 'CACHED_USER_PROFILE';

  ProfileLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheProfile(UserProfileModel profile) async {
    final profileJson = jsonEncode(profile.toJson());
    await sharedPreferences.setString(_keyProfile, profileJson);
  }

  @override
  Future<UserProfileModel?> getCachedProfile() async {
    final profileJson = sharedPreferences.getString(_keyProfile);

    if (profileJson != null) {
      final profileMap = jsonDecode(profileJson) as Map<String, dynamic>;
      return UserProfileModel.fromJson(profileMap);
    }

    return null;
  }

  @override
  Future<void> clearProfileCache() async {
    await sharedPreferences.remove(_keyProfile);
  }
}