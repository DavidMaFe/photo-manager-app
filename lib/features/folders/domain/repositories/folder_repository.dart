import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

import '../entities/folder.dart';


abstract class FolderRepository {
  Future<List<Folder>> getFolders({String? parentFolderId});
  Future<FolderContent> getFolderContent({
    required String folderId,
    int page = 0,
    int pageSize = 50,
    FileFilter filter
  });
  Future<Folder> createFolder({required String name, String? parentFolderId});
  Future<Folder> renameFolder({required String folderId, required String newName});
  Future<void> deleteFolder({required String folderId});
}