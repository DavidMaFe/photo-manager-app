import 'package:photo_manager_app/features/downloads/domain/entities/downloadable_file.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';

/// The files of the account on the server.
abstract class ServerFilesRepository {
  /// Every file outside the trash, newest first; only those of the album [folderId] (and its subalbums with
  /// [includeSubfolders]) when it is given.
  Future<List<RemoteMediaFile>> files({String? folderId, bool includeSubfolders = false});

  /// What saving these files needs (type and date). Files in the trash or deleted are left out. Their keys are kept
  /// so their content can be decrypted.
  Future<List<DownloadableFile>> downloadable(List<String> fileIds);

  /// This device has these files again: the ones it uploaded itself stop being "deleted from the device".
  Future<void> markOnDevice(List<String> fileIds);
}
