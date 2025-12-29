import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';

import '../../../../../core/errors/base/failures.dart';


class ManageFolderBloc extends Bloc<ManageFolderEvent, ManageFolderState> {

  final GetFoldersUseCase getFoldersUseCase;
  ManageFolderBloc({required this.getFoldersUseCase}) : super(const ManageFolderStarting()) {
    on<LoadFolders>(_onLoadFolders);
  }

  Future<void> _onLoadFolders(LoadFolders event, Emitter<ManageFolderState> emit) async {

    emit(const ManageFoldersLoading());

    try {

      final folders = await getFoldersUseCase();
      emit(ManageFoldersLoaded(folders: folders));

    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(ManageFolderError(failure: failure));
    }
  }
}