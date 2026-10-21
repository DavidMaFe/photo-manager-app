import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// What every line of the app says about where it happened.
class DeviceContext {
  final String appVersion;
  final String build;

  /// `android` or `ios`.
  final String platform;
  final String osVersion;
  final String deviceModel;

  const DeviceContext({
    required this.appVersion,
    required this.build,
    required this.platform,
    required this.osVersion,
    required this.deviceModel,
  });
}

/// Reads the [DeviceContext] once.
abstract class DeviceContextProvider {
  Future<DeviceContext> get();
}

class PlatformDeviceContextProvider implements DeviceContextProvider {
  DeviceContext? _cached;

  @override
  Future<DeviceContext> get() async {
    final cached = _cached;
    if (cached != null) {
      return cached;
    }
    final package = await PackageInfo.fromPlatform();
    final deviceInfo = DeviceInfoPlugin();
    final DeviceContext context;
    if (Platform.isIOS) {
      final ios = await deviceInfo.iosInfo;
      context = DeviceContext(appVersion: package.version, build: package.buildNumber, platform: 'ios',
          osVersion: ios.systemVersion, deviceModel: ios.utsname.machine);
    } else {
      final android = await deviceInfo.androidInfo;
      context = DeviceContext(appVersion: package.version, build: package.buildNumber, platform: 'android',
          osVersion: android.version.release, deviceModel: android.model);
    }
    return _cached = context;
  }
}
