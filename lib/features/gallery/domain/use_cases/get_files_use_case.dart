import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';

import '../enums/file_filter.dart';


class GetFilesUseCase {

  final GalleryRepository _repository;
  GetFilesUseCase(this._repository);

  Future<GalleryPage> call({int page = 0, int pageSize = 50, FileFilter filter = FileFilter.all}) async {

    if (page < 0) {
      page = 0;
    }

    if (pageSize <= 0) {
      pageSize = 50;
    }

    return await _repository.getFiles(page: page, pageSize: pageSize, filter: filter);
  }
}