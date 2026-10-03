import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


enum FileFilter {
  all,
  images,
  videos,
  pending;

  FileType? get fileType {
    switch (this) {
      case FileFilter.images:
        return FileType.image;
      case FileFilter.videos:
        return FileType.video;
      default:
        return null;
    }
  }

  FileStatus? get fileStatus {
    switch (this) {
      case FileFilter.pending:
        return FileStatus.pending;
      default:
        return null;
    }
  }

}