import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';


class DeleteFolderUseCase {

  final FolderRepository repository;
  DeleteFolderUseCase(this.repository);

  Future<void> call({required String folderId}) async {
    await repository.deleteFolder(folderId: folderId);
  }
}