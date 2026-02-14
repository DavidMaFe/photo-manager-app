import 'dart:convert';

import 'package:photo_manager_app/features/sync_config/data/models/sync_config_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class SyncConfigLocalDataSource {
  /// Get cached sync configuration
  /// Returns null if no configuration exists
  Future<SyncConfigModel?> getSyncConfig();

  /// Cache sync configuration
  Future<void> cacheSyncConfig(SyncConfigModel config);

  /// Clear cached sync configuration
  Future<void> clearSyncConfig();

  /// Check if sync configuration exists
  Future<bool> hasSyncConfig();
}

class SyncConfigLocalDataSourceImpl implements SyncConfigLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _keySyncConfig = 'SYNC_CONFIG';

  SyncConfigLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<SyncConfigModel?> getSyncConfig() async {
    final configJson = sharedPreferences.getString(_keySyncConfig);

    if (configJson != null) {
      final configMap = jsonDecode(configJson);
      return SyncConfigModel.fromJson(configMap);
    }

    return null;
  }

  @override
  Future<void> cacheSyncConfig(SyncConfigModel config) async {
    final configJson = jsonEncode(config.toJson());
    await sharedPreferences.setString(_keySyncConfig, configJson);
  }

  @override
  Future<void> clearSyncConfig() async {
    await sharedPreferences.remove(_keySyncConfig);
  }

  @override
  Future<bool> hasSyncConfig() async {
    return sharedPreferences.containsKey(_keySyncConfig);
  }
}
