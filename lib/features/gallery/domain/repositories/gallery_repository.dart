import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


abstract class GalleryRepository {
  Future<GalleryPage> getFiles({
    required int page,
    required int pageSize,
    required FileFilter filter
  });

  Future<PendingFiles> getPendingFileIds({FileType? type, String? folderId});
}
