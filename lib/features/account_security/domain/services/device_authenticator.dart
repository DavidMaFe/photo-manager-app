/// Device lock check (fingerprint, face or PIN) before sensitive actions.
abstract class DeviceAuthenticator {
  /// Whether the device has a screen lock the app can ask for.
  Future<bool> isAvailable();

  /// Asks for the device lock. Returns false if the user cancels or fails.
  Future<bool> authenticate(String reason);
}
