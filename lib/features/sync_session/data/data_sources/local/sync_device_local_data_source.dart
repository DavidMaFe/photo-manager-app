import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_device_model.dart';
import 'package:shared_preferences/shared_preferences.dart';


abstract class SyncDeviceLocalDataSource {
  Future<String> getDeviceUuid();
  Future<SyncDeviceModel> getCurrentDeviceInfo();
  Future<void> saveDeviceUuid(String uuid);
}


class SyncDeviceLocalDataSourceImpl implements SyncDeviceLocalDataSource {

  final SharedPreferences sharedPreferences;
  final DeviceInfoPlugin deviceInfo;

  static const String _keyDeviceUuid = 'DEVICE_UUID';

  SyncDeviceLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.deviceInfo
  });

  @override
  Future<String> getDeviceUuid() async {
    // Check if we have a cached device identifier
    final savedUuid = sharedPreferences.getString(_keyDeviceUuid);

    if(savedUuid != null && savedUuid.isNotEmpty) {
      return savedUuid;
    }

    // Get hardware-based device identifier that persists across reinstalls
    final hardwareId = await _getHardwareDeviceId();

    // Validate that we got a valid hardware ID
    if(hardwareId.isEmpty) {
      throw Exception("Failed to obtain hardware device identifier");
    }

    // Cache the hardware ID for performance
    await saveDeviceUuid(hardwareId);
    return hardwareId;
  }

  /// Gets a hardware-based device identifier that persists across app reinstalls
  /// For Android: Uses ANDROID_ID (persists across reinstalls but not factory resets)
  /// For iOS: Uses identifierForVendor (persists across reinstalls for same vendor)
  Future<String> _getHardwareDeviceId() async {
    if(Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? '';
    } else {
      throw Exception("Platform not supported: ${Platform.operatingSystem}");
    }
  }

  @override
  Future<void> saveDeviceUuid(String uuid) async {
    await sharedPreferences.setString(_keyDeviceUuid, uuid);
  }

  @override
  Future<SyncDeviceModel> getCurrentDeviceInfo() async {
    final uuid = await getDeviceUuid();

    String name;
    String model;
    String osType;
    String osVersion;

    if(Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;

      name = androidInfo.model;
      model = androidInfo.model;
      osType = "Android";
      osVersion = androidInfo.version.release;

    } else if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;

      name = iosInfo.name;
      model = iosInfo.model;
      osType = "iOS";
      osVersion = iosInfo.systemVersion;

    } else {
      throw Exception("Platform not supported: ${Platform.operatingSystem}");
    }

    final appVersion = "1.0.0"; // TODO: Obtener de package_info_plus

    return SyncDeviceModel.fromRegistrationResponse(
      id: '',
      uuid: uuid,
      name: name,
      model: model,
      osType: osType,
      osVersion: osVersion,
      appVersion: appVersion,
      userId: ''
    );
  }
}