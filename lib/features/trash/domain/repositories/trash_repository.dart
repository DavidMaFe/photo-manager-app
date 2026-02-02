import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';

abstract class TrashRepository {
  /// Get paginated list of files in trash
  ///
  /// [page] - Page number (0-indexed)
  /// [pageSize] - Number of items per page
  Future<TrashPage> getTrashFiles({
    required int page,
    required int pageSize,
  });

  /// Restore files from trash to their original folder locations
  ///
  /// [fileIds] - List of file IDs to restore
  Future<void> restoreFiles(List<String> fileIds);

  /// Permanently delete files from trash
  ///
  /// [fileIds] - List of file IDs to delete permanently
  Future<void> permanentlyDeleteFiles(List<String> fileIds);

  /// Empty entire trash (permanently delete all files)
  Future<void> emptyTrash();
}
