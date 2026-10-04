import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';


class ManageFilesUseCase {

  /// Files sent to the server per request; bigger selections go in batches.
  static const int batchSize = 100;

  final FileManagementRepository repository;
  ManageFilesUseCase(this.repository);

  Future<List<String>> call(List<String> fileIds, ManageAction action) async {

    if (fileIds.isEmpty) {
      throw Exception('Have to be at least one file selected');
    }

    final batchAction = await _actionForBatches(fileIds, action);
    final successfulIds = <String>[];
    final failedIds = <String>[];

    // Perform server-side management first, one batch at a time.
    // If a batch throws, the earlier batches are already managed on the server.
    for (var start = 0; start < fileIds.length; start += batchSize) {
      final end = start + batchSize < fileIds.length ? start + batchSize : fileIds.length;
      final result = await repository.manageFiles(fileIds.sublist(start, end), batchAction);
      successfulIds.addAll(result.successfulIds);
      failedIds.addAll(result.failedIds);
    }

    // If user wants to remove files from device, delete local files after server deletion
    // This only deletes files that have local mappings (uploaded from this device)
    // If local deletion fails, we don't propagate the error since server deletion succeeded
    if (!action.keepOnDevice && successfulIds.isNotEmpty) {
      try {
        await repository.deleteLocalFiles(successfulIds);
      } catch (e) {
        // Silently catch local deletion errors - server operation already succeeded
        // Files may remain locally if they were uploaded from another device
      }
    }

    return failedIds;
  }

  /// A new album has to be created once: with several batches, create it first
  /// and send every batch to it. A single batch lets the server create it.
  Future<ManageAction> _actionForBatches(List<String> fileIds, ManageAction action) async {
    if (action.serverAction != ServerAction.newFolder || fileIds.length <= batchSize) {
      return action;
    }
    final folder = await repository.createFolder(action.folderName!.trim());
    return ManageAction(serverAction: ServerAction.folder, folderId: folder.id, keepOnDevice: action.keepOnDevice);
  }
}
