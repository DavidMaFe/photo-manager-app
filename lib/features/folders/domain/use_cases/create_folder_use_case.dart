import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';

import '../entities/folder.dart';


class CreateFolderUseCase {

  final FolderRepository repository;
  CreateFolderUseCase(this.repository);
  
  Future<Folder> call({required String name, String? parentFolderId}) async {

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw Exception("Invalid name");
    }

    return await repository.createFolder(name: trimmedName, parentFolderId: parentFolderId);
  }
}