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

    // Perform server-side management first
    final result = await repository.manageFiles(fileIds, action);

    // If user wants to remove files from device, delete local files after server deletion
    // This only deletes files that have local mappings (uploaded from this device)
    // If local deletion fails, we don't propagate the error since server deletion succeeded
    if (!action.keepOnDevice && result.successfulIds.isNotEmpty) {
      try {
        await repository.deleteLocalFiles(result.successfulIds);
      } catch (e) {
        // Silently catch local deletion errors - server operation already succeeded
        // Files may remain locally if they were uploaded from another device
      }
    }

    return result.failedIds;
  }
}