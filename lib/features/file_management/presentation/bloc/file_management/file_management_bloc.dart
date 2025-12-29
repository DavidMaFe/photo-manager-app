import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/manage_files_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';

import '../../../../../core/errors/base/failures.dart';


class FileManagementBloc extends Bloc<FileManagementEvent, FileManagementState> {

  final ManageFilesUseCase manageFilesUseCase;

  FileManagementBloc({required this.manageFilesUseCase}) : super(const FileManagementStarting()) {
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
      } else {
        final successCount = event.fileIds.length - failedFiles.length;
        emit(FileManagementPartialSuccess(successCount: successCount,
            failedCount: failedFiles.length, failedFiles: failedFiles));
      }

    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FileManagementError(failure: failure));
    }
  }
}