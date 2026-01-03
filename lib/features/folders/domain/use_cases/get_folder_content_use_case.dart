import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


class GetFolderContentUseCase {

  final FolderRepository repository;
  GetFolderContentUseCase(this.repository);

  Future<FolderContent> call({
    required String folderId,
    int page = 0,
    int pageSize = 50,
    FileFilter filter = FileFilter.all,
  }) async {
    return await repository.getFolderContent(folderId: folderId, page: page,
        pageSize: pageSize, filter: filter);
  }
}