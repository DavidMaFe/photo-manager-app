import 'dart:typed_data';

import 'package:photo_manager_app/features/encrypted_media/data/data_sources/encrypted_media_remote_data_source.dart';
import 'package:photo_manager_app/features/encrypted_media/data/data_sources/encrypted_object_cache.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_range.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/repositories/encrypted_media_repository.dart';

class EncryptedMediaDataRepository implements EncryptedMediaRepository {
  final EncryptedMediaRemoteDataSource remoteDataSource;
  final EncryptedObjectCache cache;

  /// Downloads in progress, so the same object is never downloaded twice at the same time.
  final Map<String, Future<Uint8List>> _downloads = {};

  EncryptedMediaDataRepository({required this.remoteDataSource, required this.cache});

  @override
  Future<Uint8List> object(String fileId, MediaVariant variant) async {
    final cached = await cache.read(fileId, variant);
    if (cached != null) {
      return cached;
    }
    final key = '${variant.name}/$fileId';
    return _downloads[key] ??= () async {
      try {
        final bytes = await remoteDataSource.getObject(fileId, variant);
        await cache.write(fileId, variant, bytes);
        return bytes;
      } finally {
        _downloads.remove(key);
      }
    }();
  }

  @override
  Future<EncryptedRange> originalRange(String fileId, int start, int end) async {
    // A video already downloaded whole (e.g. watched before) is read from the cache
    final cached = await cache.read(fileId, MediaVariant.original);
    if (cached != null && end < cached.length) {
      return EncryptedRange(bytes: Uint8List.sublistView(cached, start, end + 1), totalLength: cached.length);
    }
    return remoteDataSource.getOriginalRange(fileId, start, end);
  }

  @override
  Future<void> clearCache() => cache.clear();
}
