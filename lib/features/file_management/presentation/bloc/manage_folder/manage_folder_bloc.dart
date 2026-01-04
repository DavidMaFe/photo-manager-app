import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/file_management/domain/use_cases/get_folders_use_case.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_state.dart';

import '../../../../../core/errors/base/failures.dart';


class ManageFolderBloc extends Bloc<ManageFolderEvent, ManageFolderState> {

  final GetFoldersUseCase getFoldersUseCase;
  final AppEventBus eventBus;
  StreamSubscription<FolderUpdatedEvent>? _folderUpdateSubscription;

  ManageFolderBloc({
    required this.getFoldersUseCase,
    required this.eventBus,
  }) : super(const ManageFolderStarting()) {
    on<LoadFolders>(_onLoadFolders);

    // Listen to folder update events and auto-refresh
    _folderUpdateSubscription = eventBus.on<FolderUpdatedEvent>().listen((_) {
      add(const LoadFolders());
    });
  }

  @override
  Future<void> close() {
    _folderUpdateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadFolders(LoadFolders event, Emitter<ManageFolderState> emit) async {

    // Only show loading if we're not already loaded (silent refresh for updates)
    if (state is! ManageFoldersLoaded) {
      emit(const ManageFoldersLoading());
    }

    try {

      final folders = await getFoldersUseCase();
      emit(ManageFoldersLoaded(folders: folders));

    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(ManageFolderError(failure: failure));
    }
  }
}