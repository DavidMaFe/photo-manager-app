import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';

import '../entities/folder.dart';


class RenameFolderUseCase {

  final FolderRepository repository;
  RenameFolderUseCase(this.repository);

  Future<Folder> call ({required String folderId, required String newName}) async {

    final trimmedName = newName.trim();
    if (trimmedName.isEmpty) {
      throw Exception("Invalid name");
    }

    return await repository.renameFolder(folderId: folderId, newName: trimmedName);
  }
}