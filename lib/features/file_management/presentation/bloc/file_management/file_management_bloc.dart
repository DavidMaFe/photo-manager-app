import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';

import '../../../../../core/errors/base/failures.dart';


class FileManagementBloc extends Bloc<FileManagementEvent, FileManagementState> {

  final ManageFilesUseCase manageFilesUseCase;
  final AppEventBus eventBus;

  FileManagementBloc({
    required this.manageFilesUseCase,
    required this.eventBus,
  }) : super(const FileManagementStarting()) {
    on<ManagedFilesRequested>(_onManageFilesRequested);
  }

  Future<void> _onManageFilesRequested(ManagedFilesRequested event, Emitter<FileManagementState> emit) async {

    emit(const FileManagementLoading());

    try {

      final failedFiles = await manageFilesUseCase(event.fileIds, event.action);

      if(failedFiles.isEmpty) {
        final count = event.fileIds.length;
        final message = count == 1 ? 'Files managed correctly' : '$count files managed';
        emit(FileManagementSuccess(message: message, processedCount: count));

        // Broadcast file update event
        _broadcastFileUpdateEvent(event.fileIds, event.action);
      } else {
        final successCount = event.fileIds.length - failedFiles.length;
        emit(FileManagementPartialSuccess(successCount: successCount,
            failedCount: failedFiles.length, failedFiles: failedFiles));

        // Broadcast for successful files only
        if (successCount > 0) {
          final successfulFileIds = event.fileIds
              .where((id) => !failedFiles.contains(id))
              .toList();
          _broadcastFileUpdateEvent(successfulFileIds, event.action);
        }
      }

    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FileManagementError(failure: failure));
    }
  }

  void _broadcastFileUpdateEvent(List<String> fileIds, ManageAction action) {
    // Determine the update type based on the server action
    late FileUpdateType updateType;
    List<String>? affectedFolderIds;

    switch (action.serverAction) {
      case ServerAction.delete:
        updateType = FileUpdateType.deleted;
        break;
      case ServerAction.folder:
      case ServerAction.newFolder:
        updateType = FileUpdateType.moved;
        affectedFolderIds = action.folderId != null ? [action.folderId!] : null;
        break;
      case ServerAction.save:
        updateType = FileUpdateType.updated;
        break;
    }

    // Broadcast the file updated event
    eventBus.fire(FileUpdatedEvent(
      affectedFileIds: fileIds,
      affectedFolderIds: affectedFolderIds,
      updateType: updateType,
    ));

    // Invalidate caches
    eventBus.fire(const CacheInvalidationEvent(
      type: CacheInvalidationType.files,
    ));

    // If folders are affected, invalidate folder caches too
    if (affectedFolderIds != null || action.serverAction == ServerAction.newFolder) {
      eventBus.fire(const CacheInvalidationEvent(
        type: CacheInvalidationType.folders,
      ));

      // Also broadcast FolderUpdatedEvent so FolderBloc can refresh file counts
      eventBus.fire(FolderUpdatedEvent(
        affectedFolderIds: affectedFolderIds,
        updateType: FolderUpdateType.updated,
      ));
    }
  }
}