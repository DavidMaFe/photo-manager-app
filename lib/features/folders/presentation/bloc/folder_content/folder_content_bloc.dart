import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folder_content_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';

import '../../../../../core/errors/base/failures.dart';
import '../../../../../core/errors/handler/error_handler.dart';
import '../../../../gallery/domain/enums/file_filter.dart';
import '../../../domain/entities/folder.dart';


class FolderContentBloc extends Bloc<FolderContentEvent, FolderContentState> {

  final GetFolderContentUseCase getFolderContentUseCase;

  String? _currentFolderId;
  FileFilter _currentFilter = FileFilter.all;
  int _currentPage = 0;

  FolderContentBloc({required this.getFolderContentUseCase}) : super(const FolderContentStarting()) {
    on<LoadFolderContent>(_onLoadFolderContent);
    on<RefreshFolderContent>(_onRefreshFolderContent);
    on<LoadMoreFiles>(_onLoadMoreFiles);
    on<FilterFilesInFolder>(_onFilterFiles);
    on<EnterSelectionMode>(_onEnterSelectionMode);
    on<ExitSelectionMode>(_onExitSelectionMode);
    on<ToggleFileSelection>(_onToggleFileSelection);
  }

  Future<void> _onLoadFolderContent(LoadFolderContent event, Emitter<FolderContentState> emit) async {

    Folder? previousFolder;
    List<Folder>? previousSubfolders;
    if (state is FolderContentLoaded) {
      previousFolder = (state as FolderContentLoaded).currentFolder;
      previousSubfolders = (state as FolderContentLoaded).subfolders;
    }

    emit(FolderContentLoading(previousFolder: previousFolder, previousSubfolders: previousSubfolders));
    _currentFolderId = event.folderId;
    _currentFilter = FileFilter.all;
    _currentPage = 0;

    try {

      final content = await getFolderContentUseCase(folderId: event.folderId, filter: _currentFilter);
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
        currentFolder: content.folder,
        subfolders: content.subfolders,
        files: content.files,
        hasMoreFiles: content.hasMoreFiles,
        currentFilter: _currentFilter
      ));
    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderContentError(failure));
    }
  }

  Future<void> _onRefreshFolderContent(RefreshFolderContent event, Emitter<FolderContentState> emit) async {

    if (_currentFolderId == null) return;
    _currentPage = 0;

    try {

      final content = await getFolderContentUseCase(
        folderId: _currentFolderId!, filter: _currentFilter
      );
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
          currentFolder: content.folder,
          subfolders: content.subfolders,
          files: content.files,
          hasMoreFiles: content.hasMoreFiles,
          currentFilter: _currentFilter
      ));
    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderContentError(failure));
    }
  }

  Future<void> _onLoadMoreFiles(LoadMoreFiles event, Emitter<FolderContentState> emit) async {

    if (state is! FolderContentLoaded) return;
    final currentState = state as FolderContentLoaded;
    if (!currentState.hasMoreFiles) return;

    emit(FolderContentLoadingMore(
        currentFolder: currentState.currentFolder,
        subfolders: currentState.subfolders,
        files: currentState.files,
        currentFilter: currentState.currentFilter
    ));

    try {

      _currentPage++;

      final content = await getFolderContentUseCase(
          folderId: currentState.currentFolder.id,
          page: _currentPage,
          filter: _currentFilter
      );

      final allFiles = [...currentState.files, ...content.files];
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
        currentFolder: content.folder,
        subfolders: content.subfolders,
        files: allFiles,
        hasMoreFiles: content.hasMoreFiles,
        currentFilter: _currentFilter
      ));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderContentError(failure));
    }
  }

  Future<void> _onFilterFiles(FilterFilesInFolder event, Emitter<FolderContentState> emit) async {

    if (_currentFolderId == null) return;
    if (state is! FolderContentLoaded) return;

    _currentFilter = event.filter;
    _currentPage = 0;

    Folder? previousFolder;
    List<Folder>? previousSubfolders;
    if (state is FolderContentLoaded) {
      previousFolder = (state as FolderContentLoaded).currentFolder;
      previousSubfolders = (state as FolderContentLoaded).subfolders;
    }

    emit(FolderContentLoading(previousFolder: previousFolder, previousSubfolders: previousSubfolders));

    try {

      final content = await getFolderContentUseCase(
        folderId: _currentFolderId!,
        filter: _currentFilter
      );
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
          currentFolder: content.folder,
          subfolders: content.subfolders,
          files: content.files,
          hasMoreFiles: content.hasMoreFiles,
          currentFilter: _currentFilter
      ));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderContentError(failure));
    }
  }

  void _onEnterSelectionMode(EnterSelectionMode event, Emitter<FolderContentState> emit) async {

    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      emit(currentState.copyWith(isSelectionMode: true));
    }
  }

  void _onExitSelectionMode(ExitSelectionMode event, Emitter<FolderContentState> emit) async {

    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      emit(currentState.copyWith(isSelectionMode: false, selectedFileIds: {}));
    }
  }

  void _onToggleFileSelection(ToggleFileSelection event, Emitter<FolderContentState> emit) async {

    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      final newSelectedIds = Set<String>.from(currentState.selectedFileIds);

      if (newSelectedIds.contains(event.fileId)) {
        newSelectedIds.remove(event.fileId);
      } else {
        newSelectedIds.add(event.fileId);
      }

      emit(currentState.copyWith(selectedFileIds: newSelectedIds));
    }
  }
}