import 'package:photo_manager_app/features/downloads/data/data_sources/server_files_remote_data_source.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/domain/repositories/server_files_repository.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_device_repository.dart';

class ServerFilesDataRepository implements ServerFilesRepository {
  final ServerFilesRemoteDataSource remoteDataSource;
  final FileKeyRepository fileKeyRepository;
  final SyncDeviceRepository syncDeviceRepository;

  ServerFilesDataRepository({
    required this.remoteDataSource,
    required this.fileKeyRepository,
    required this.syncDeviceRepository,
  });

  @override
  Future<List<RemoteMediaFile>> files({String? folderId, bool includeSubfolders = false}) =>
      remoteDataSource.getFiles(folderId: folderId, includeSubfolders: includeSubfolders);

  @override
  Future<List<DownloadableFile>> downloadable(List<String> fileIds) async {
    final result = <DownloadableFile>[];
    for (final chunk in _chunks(fileIds)) {
      final files = await remoteDataSource.getFilesByIds(chunk);
      fileKeyRepository.remember(files.map((file) => file.encryptedRef).nonNulls);
      result.addAll(files.map((file) => DownloadableFile(id: file.id, type: file.type, capturedAt: file.capturedAt)));
    }
    return result;
  }

  @override
  Future<void> markOnDevice(List<String> fileIds) async {
    if (fileIds.isEmpty) return;
    final deviceUuid = await syncDeviceRepository.getDeviceUuid();
    for (final chunk in _chunks(fileIds)) {
      await remoteDataSource.markOnDevice(deviceUuid, chunk);
    }
  }

  static Iterable<List<String>> _chunks(List<String> ids) sync* {
    const size = ServerFilesRemoteDataSourceImpl.maxIdsPerRequest;
    for (var start = 0; start < ids.length; start += size) {
      yield ids.sublist(start, start + size < ids.length ? start + size : ids.length);
    }
  }
}
