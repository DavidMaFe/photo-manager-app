import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/file_mapping_repository.dart';

class FileMappingDataRepository implements FileMappingRepository {
  final AppDatabase database;

  FileMappingDataRepository({required this.database});

  @override
  Future<Map<String, String>> all() => database.getAllMappings();

  /// The hash of the content is not known here (the column is not used to look files up): it stays empty.
  @override
  Future<void> save({required String serverId, required String localId, required String localPath}) =>
      database.saveFileMapping(serverId: serverId, localId: localId, localPath: localPath, hash: '');
}
