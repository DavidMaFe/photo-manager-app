/// Which file of the gallery of this device is each file of the server (the `file_mapping` table).
abstract class FileMappingRepository {
  /// Server id → id in the gallery.
  Future<Map<String, String>> all();

  Future<void> save({required String serverId, required String localId, required String localPath});
}
