import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';

import '../entities/folder.dart';


class GetFoldersListUseCase {

  final FolderRepository repository;
  GetFoldersListUseCase(this.repository);

  Future<List<Folder>> call({String? parentFolderId}) async {
    return await repository.getFolders(parentFolderId: parentFolderId);
  }
}