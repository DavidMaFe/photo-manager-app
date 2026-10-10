import 'dart:async';

import 'package:photo_manager_app/features/encrypted_media/data/data_sources/encrypted_media_remote_data_source.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_failures.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';

/// Keys in memory, filled by the lists of files. The ids asked in the same moment (the covers of a screen of albums)
/// go to the server together, in batches of at most 200.
class FileKeyDataRepository implements FileKeyRepository {
  final EncryptedMediaRemoteDataSource remoteDataSource;
  final Map<String, EncryptedFileRef> _refs = {};
  final Map<String, Completer<EncryptedFileRef>> _pending = {};
  bool _flushScheduled = false;

  FileKeyDataRepository({required this.remoteDataSource});

  @override
  void remember(Iterable<EncryptedFileRef> refs) {
    for (final ref in refs) {
      _refs[ref.fileId] = ref;
    }
  }

  @override
  Future<EncryptedFileRef> refFor(String fileId) {
    final known = _refs[fileId];
    if (known != null) {
      return Future.value(known);
    }
    final completer = _pending.putIfAbsent(fileId, Completer.new);
    if (!_flushScheduled) {
      _flushScheduled = true;
      // Waits for the rest of the ids of the frame
      Timer.run(_flush);
    }
    return completer.future;
  }

  @override
  void clear() {
    _refs.clear();
  }

  Future<void> _flush() async {
    _flushScheduled = false;
    final batch = Map.of(_pending);
    _pending.clear();
    final ids = batch.keys.toList();
    for (var start = 0; start < ids.length; start += EncryptedMediaRemoteDataSourceImpl.maxIdsPerRequest) {
      final chunk = ids.sublist(start,
          (start + EncryptedMediaRemoteDataSourceImpl.maxIdsPerRequest).clamp(0, ids.length));
      try {
        remember(await remoteDataSource.getFileKeys(chunk));
        for (final id in chunk) {
          final ref = _refs[id];
          ref == null ? batch[id]!.completeError(const UnencryptedFileFailure()) : batch[id]!.complete(ref);
        }
      } catch (e, stack) {
        for (final id in chunk) {
          batch[id]!.completeError(e, stack);
        }
      }
    }
  }
}
