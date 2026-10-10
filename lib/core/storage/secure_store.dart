/// Key-value storage protected by the platform: Android Keystore and iOS Keychain.
///
/// Holds secrets (tokens and master keys). Everything else stays in SharedPreferences.
abstract class SecureStore {
  Future<String?> read(String key);

  Future<void> write(String key, String value);

  Future<void> delete(String key);

  Future<Map<String, String>> readAll();
}
