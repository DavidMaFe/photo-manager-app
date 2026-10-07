import 'package:local_auth/local_auth.dart';
import 'package:photo_manager_app/features/account_security/domain/services/device_authenticator.dart';

/// Fingerprint, face or the device PIN/pattern, through local_auth.
class LocalAuthDeviceAuthenticator implements DeviceAuthenticator {
  final LocalAuthentication localAuthentication;

  LocalAuthDeviceAuthenticator({LocalAuthentication? localAuthentication})
      : localAuthentication = localAuthentication ?? LocalAuthentication();

  @override
  Future<bool> isAvailable() async {
    try {
      return await localAuthentication.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> authenticate(String reason) async {
    try {
      // biometricOnly false: the device PIN, pattern or password also counts
      return await localAuthentication.authenticate(localizedReason: reason, biometricOnly: false);
    } catch (_) {
      return false;
    }
  }
}
