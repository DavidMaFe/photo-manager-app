import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/temporary_files.dart';

/// Files in the private temporary directory of the app (uploads/), which other apps cannot read.
class AppTemporaryFiles implements TemporaryFiles {
  final Future<Directory> Function() _baseDirectory;
  int _counter = 0;

  AppTemporaryFiles({Future<Directory> Function()? baseDirectory})
      : _baseDirectory = baseDirectory ?? getTemporaryDirectory;

  @override
  Future<File> create(String suffix) async {
    final directory = await Directory('${(await _baseDirectory()).path}/uploads').create(recursive: true);
    final name = '${DateTime.now().microsecondsSinceEpoch}_${_counter++}$suffix';
    return File('${directory.path}/$name').create();
  }
}
