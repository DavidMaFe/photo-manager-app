import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/create_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/delete_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/rename_folder_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder/folder_state.dart';

import '../../../../../core/errors/base/failures.dart';
import '../../../../../core/errors/handler/error_handler.dart';
import '../../../domain/use_cases/get_folders_list_use_case.dart';


class FolderBloc extends Bloc<FolderEvent, FolderState> {

  final GetFoldersListUseCase getFoldersUseCase;
  final CreateFolderUseCase createFolderUseCase;
  final RenameFolderUseCase renameFolderUseCase;
  final DeleteFolderUseCase deleteFolderUseCase;

  FolderBloc({
    required this.getFoldersUseCase,
    required this.createFolderUseCase,
    required this.renameFolderUseCase,
    required this.deleteFolderUseCase
  }) : super(const FolderStarting()) {
    on<LoadFolders>(_onLoadFolders);
    on<RefreshFolders>(_onRefreshFolders);
    on<CreateFolderRequested>(_onCreateFolder);
    on<RenameFolderRequested>(_onRenameFolder);
    on<DeleteFolderRequested>(_onDeleteFolder);
  }

  Future<void> _onLoadFolders(LoadFolders event, Emitter<FolderState> emit) async {

    try {
      final folders = await getFoldersUseCase(parentFolderId: event.parentFolderId);
      emit(FolderLoaded(folders: folders, currentParentId: event.parentFolderId));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    }
  }

  Future<void> _onRefreshFolders(RefreshFolders event, Emitter<FolderState> emit) async {

    String? currentParentId;
    if (state is FolderLoaded) {
      currentParentId = (state as FolderLoaded).currentParentId;
    }

    try {
      final folders = await getFoldersUseCase(parentFolderId: currentParentId);
      emit(FolderLoaded(folders: folders, currentParentId: currentParentId));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    }
  }

  Future<void> _onCreateFolder(CreateFolderRequested event, Emitter<FolderState> emit) async {

    emit(const FolderOperationLoading(operation: 'create'));

    try {
      await createFolderUseCase(name: event.name, parentFolderId: event.parentFolderId);
      emit(const FolderOperationSuccess(operation: 'create', message: 'success'));
      add(LoadFolders(parentFolderId: event.parentFolderId));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    }
  }

  Future<void> _onRenameFolder(RenameFolderRequested event, Emitter<FolderState> emit) async {

    emit(FolderOperationLoading(operation: 'rename'));

    try {
      await renameFolderUseCase(folderId: event.folderId, newName: event.newName);
      emit(const FolderOperationSuccess(operation: 'rename', message: 'success'));

      if (state is FolderLoaded) {
        final currentParentId = (state as FolderLoaded).currentParentId;
        add(LoadFolders(parentFolderId: currentParentId));
      } else {
        add(const LoadFolders());
      }
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    }
  }

  Future<void> _onDeleteFolder(DeleteFolderRequested event, Emitter<FolderState> emit) async {

    emit(FolderOperationLoading(operation: 'delete'));

    try {
      await deleteFolderUseCase(folderId: event.folderId);
      emit(const FolderOperationSuccess(operation: 'delete', message: 'success'));

      if (state is FolderLoaded) {
        final currentParentId = (state as FolderLoaded).currentParentId;
        add(LoadFolders(parentFolderId: currentParentId));
      } else {
        add(const LoadFolders());
      }
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    }
  }
}