import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:share_plus/share_plus.dart';

/// Temporary files of the share sheet, in `<cache>/share_tmp/` (each in its own folder, so they keep their original
/// name), the files of the gallery and the share sheet itself.
abstract class ShareLocalDataSource {
  Future<String> galleryFilePath(String localId);
  Future<String> writeTemporary(String fileName, Stream<Uint8List> bytes);
  Future<void> share(List<String> paths);
  Future<void> clearTemporary();
}

class ShareLocalDataSourceImpl implements ShareLocalDataSource {
  static const String folderName = 'share_tmp';

  final Future<Directory> Function() cacheDirectory;
  final Future<File?> Function(String localId) galleryFile;
  final Future<void> Function(List<String> paths) openShareSheet;
  int _counter = 0;

  ShareLocalDataSourceImpl({
    Future<Directory> Function()? cacheDirectory,
    Future<File?> Function(String localId)? galleryFile,
    Future<void> Function(List<String> paths)? openShareSheet,
  })  : cacheDirectory = cacheDirectory ?? getTemporaryDirectory,
        galleryFile = galleryFile ?? _photoManagerFile,
        openShareSheet = openShareSheet ?? _sharePlus;

  @override
  Future<String> galleryFilePath(String localId) async {
    final file = await galleryFile(localId);
    if (file == null) {
      throw const FileSystemException('The file is no longer in the gallery');
    }
    return file.path;
  }

  @override
  Future<String> writeTemporary(String fileName, Stream<Uint8List> bytes) async {
    final folder = Directory('${(await _root()).path}/${DateTime.now().microsecondsSinceEpoch}_${_counter++}');
    await folder.create(recursive: true);
    final file = File('${folder.path}/${_safeName(fileName)}');
    final sink = file.openWrite();
    try {
      await sink.addStream(bytes);
      await sink.flush();
    } finally {
      await sink.close();
    }
    return file.path;
  }

  @override
  Future<void> share(List<String> paths) => openShareSheet(paths);

  @override
  Future<void> clearTemporary() async {
    final root = await _root();
    if (await root.exists()) {
      await root.delete(recursive: true);
    }
  }

  Future<Directory> _root() async => Directory('${(await cacheDirectory()).path}/$folderName');

  static String _safeName(String name) {
    final safe = name.replaceAll(RegExp(r'[\\/:*?"<>|\x00-\x1F]'), '_').trim();
    return safe.isEmpty || safe == '.' || safe == '..' ? 'file' : safe;
  }

  static Future<File?> _photoManagerFile(String localId) async =>
      (await AssetEntity.fromId(localId))?.originFile;

  static Future<void> _sharePlus(List<String> paths) async {
    await SharePlus.instance.share(ShareParams(files: [for (final path in paths) XFile(path)]));
  }
}
