import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:photo_manager_app/core/storage/secure_store.dart';

/// [SecureStore] on flutter_secure_storage.
///
/// iOS: readable after the first unlock since boot and never copied to another device ("this device"), so WorkManager
/// can sync in the background while the phone is locked (docs/e2ee-spec.md, section 8.3).
class FlutterSecureStore implements SecureStore {
  static const FlutterSecureStorage defaultStorage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );

  final FlutterSecureStorage storage;

  const FlutterSecureStore({this.storage = defaultStorage});

  @override
  Future<String?> read(String key) => storage.read(key: key);

  @override
  Future<void> write(String key, String value) => storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => storage.delete(key: key);

  @override
  Future<Map<String, String>> readAll() => storage.readAll();
}
