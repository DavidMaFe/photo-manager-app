import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';


class ManageFilesUseCase {

  final FileManagementRepository repository;
  ManageFilesUseCase(this.repository);

  Future<List<String>> call(List<String> fileIds, ManageAction action) async {

    if (fileIds.isEmpty) {
      throw Exception('Have to be at least one file selected');
    }

    if(fileIds.length > 100) {
      throw Exception('Too many files. Max 100 files per operation');
    }

    final result = await repository.manageFiles(fileIds, action);
    if (!action.keepOnDevice && result.successfulIds.isNotEmpty) {
      await repository.deleteLocalFiles(
        result.successfulIds
      );
    }

    return result.failedIds;
  }
}