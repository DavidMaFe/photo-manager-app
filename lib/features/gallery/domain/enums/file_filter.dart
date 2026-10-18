import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


enum FileFilter {
  all,
  favorites,
  images,
  videos,
  pending,

  /// Files this phone does not have (computed on the device, ROADMAP-downloads-and-account-deletion.md).
  notOnDevice;

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

  bool get onlyFavorites => this == FileFilter.favorites;

  bool get onlyNotOnDevice => this == FileFilter.notOnDevice;

  FileStatus? get fileStatus {
    switch (this) {
      case FileFilter.pending:
        return FileStatus.pending;
      default:
        return null;
    }
  }

}