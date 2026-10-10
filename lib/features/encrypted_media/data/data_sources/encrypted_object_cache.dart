import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/media_variant.dart';

/// Encrypted objects (PMEF, exactly as downloaded) in the private cache directory of the app. Nothing decrypted is
/// written to disk. When the total size goes over [maxBytes], the least recently used objects are removed.
class EncryptedObjectCache {
  static const int defaultMaxBytes = 500 * 1024 * 1024;

  final Future<Directory> Function() _baseDirectory;
  final int maxBytes;
  Directory? _directory;

  EncryptedObjectCache({Future<Directory> Function()? baseDirectory, this.maxBytes = defaultMaxBytes})
      : _baseDirectory = baseDirectory ?? getTemporaryDirectory;

  Future<Uint8List?> read(String fileId, MediaVariant variant) async {
    final file = await _file(fileId, variant);
    try {
      final bytes = await file.readAsBytes();
      // The last access decides what is removed first
      await file.setLastModified(DateTime.now());
      return bytes;
    } on FileSystemException {
      return null;
    }
  }

  Future<void> write(String fileId, MediaVariant variant, Uint8List bytes) async {
    final file = await _file(fileId, variant);
    await file.parent.create(recursive: true);
    // Written aside and renamed, so a read never sees half an object
    final partial = File('${file.path}.part');
    await partial.writeAsBytes(bytes, flush: true);
    await partial.rename(file.path);
    await _enforceLimit();
  }

  Future<void> clear() async {
    final directory = await _root();
    if (await directory.exists()) {
      await directory.delete(recursive: true);
    }
  }

  Future<void> _enforceLimit() async {
    final directory = await _root();
    final files = <({File file, int size, DateTime used})>[];
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File && !entity.path.endsWith('.part')) {
        final stat = await entity.stat();
        files.add((file: entity, size: stat.size, used: stat.modified));
      }
    }
    var total = files.fold<int>(0, (sum, entry) => sum + entry.size);
    if (total <= maxBytes) {
      return;
    }
    files.sort((a, b) => a.used.compareTo(b.used));
    for (final entry in files) {
      if (total <= maxBytes) {
        break;
      }
      try {
        await entry.file.delete();
        total -= entry.size;
      } on FileSystemException {
        // Removed meanwhile
      }
    }
  }

  Future<File> _file(String fileId, MediaVariant variant) async =>
      File('${(await _root()).path}/${variant.name}/$fileId.pmef');

  Future<Directory> _root() async => _directory ??= Directory('${(await _baseDirectory()).path}/encrypted_media');
}
