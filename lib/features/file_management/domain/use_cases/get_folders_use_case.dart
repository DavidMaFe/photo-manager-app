import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';


class GetFoldersUseCase {

  final FileManagementRepository repository;
  GetFoldersUseCase(this.repository);

  Future<List<ManageFolder>> call() async {
    return await repository.getFolders();
  }
}