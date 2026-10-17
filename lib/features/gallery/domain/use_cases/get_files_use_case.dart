import 'package:photo_manager_app/features/downloads/domain/services/on_device_presence.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';

import '../enums/file_filter.dart';


class GetFilesUseCase {

  final GalleryRepository _repository;

  /// What this phone is missing, for [FileFilter.notOnDevice].
  final OnDevicePresence? _presence;

  GetFilesUseCase(this._repository, [this._presence]);

  Future<GalleryPage> call({int page = 0, int pageSize = 50, FileFilter filter = FileFilter.all}) async {

    if (page < 0) {
      page = 0;
    }

    if (pageSize <= 0) {
      pageSize = 50;
    }

    if (filter.onlyNotOnDevice) {
      return _notOnDevice(page, pageSize);
    }

    return await _repository.getFiles(page: page, pageSize: pageSize, filter: filter);
  }

  /// A page of the files this phone is missing, newest first. The server only knows them by id: the page is cut from
  /// [OnDevicePresence] and its files are asked by id.
  Future<GalleryPage> _notOnDevice(int page, int pageSize) async {
    final presence = _presence;
    if (presence == null) return GalleryPage.empty();
    if (!presence.isKnown) {
      await presence.refresh();
    }
    final missing = presence.missing;
    final start = page * pageSize;
    final ids = [for (final file in missing.skip(start).take(pageSize)) file.id];
    final (files, pending) = await (
      ids.isEmpty ? Future.value(<GalleryFile>[]) : _repository.getFilesByIds(ids),
      _repository.getPendingFileIds(),
    ).wait;
    return GalleryPage(
      files: files,
      currentPage: page,
      pageSize: pageSize,
      hasNext: start + ids.length < missing.length,
      totalFilesCount: missing.length,
      totalPendingCount: pending.fileIds.length,
    );
  }
}