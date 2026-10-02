import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_folder_content_use_case.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_event.dart';
import 'package:photo_manager_app/features/folders/presentation/bloc/folder_content/folder_content_state.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


class FolderContentBloc extends Bloc<FolderContentEvent, FolderContentState> {

  final GetFolderContentUseCase getFolderContentUseCase;
  final AppEventBus eventBus;

  String? _currentFolderId;
  FileFilter _currentFilter = FileFilter.all;
  int _currentPage = 0;

  StreamSubscription<FileUpdatedEvent>? _fileUpdateSubscription;
  StreamSubscription<FolderUpdatedEvent>? _folderUpdateSubscription;

  FolderContentBloc({
    required this.getFolderContentUseCase,
    required this.eventBus,
  }) : super(const FolderContentStarting()) {
    on<LoadFolderContent>(_onLoadFolderContent);
    on<RefreshFolderContent>(_onRefreshFolderContent);
    on<LoadMoreFiles>(_onLoadMoreFiles);
    on<FilterFilesInFolder>(_onFilterFiles);
    on<EnterSelectionMode>(_onEnterSelectionMode);
    on<ExitSelectionMode>(_onExitSelectionMode);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<SelectAllFiles>(_onSelectAllFiles);
    on<DeselectAllFiles>(_onDeselectAllFiles);

    // Listen to file updates (files moved in/out of this folder)
    _fileUpdateSubscription = eventBus.on<FileUpdatedEvent>().listen((event) {
      // Only refresh if files were moved or if this folder might be affected
      if (event.updateType == FileUpdateType.moved ||
          event.updateType == FileUpdateType.deleted ||
          (event.affectedFolderIds != null &&
              event.affectedFolderIds!.contains(_currentFolderId))) {
        add(const RefreshFolderContent());
      }
    });

    // Listen to folder updates (subfolders created/deleted/renamed)
    _folderUpdateSubscription = eventBus.on<FolderUpdatedEvent>().listen((_) {
      add(const RefreshFolderContent());
    });
  }

  @override
  Future<void> close() {
    _fileUpdateSubscription?.cancel();
    _folderUpdateSubscription?.cancel();
    return super.close();
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
      final groupedFiles = DateGroupingUtil.groupFilesByDate(content.files);
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
        currentFolder: content.folder,
        subfolders: content.subfolders,
        files: content.files,
        groupedFiles: groupedFiles,
        hasMoreFiles: content.hasMoreFiles,
        totalFilesCount: content.totalFilesCount,
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

    // Preserve selection mode state
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};

    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      isSelectionMode = currentState.isSelectionMode;
      selectedFileIds = currentState.selectedFileIds;
      // Signal refresh in progress — keeps CustomScrollView alive so scroll position is preserved
      emit(currentState.copyWith(isRefreshing: true));
    }

    try {

      final content = await getFolderContentUseCase(
        folderId: _currentFolderId!, filter: _currentFilter
      );
      final groupedFiles = DateGroupingUtil.groupFilesByDate(content.files);

      // Clean up selectedFileIds - remove any IDs that no longer exist in the file list
      final currentFileIds = content.files.map((f) => f.id).toSet();
      final cleanedSelectedIds = selectedFileIds.where((id) => currentFileIds.contains(id)).toSet();

      // Exit selection mode if no files remain selected
      final shouldExitSelectionMode = isSelectionMode && cleanedSelectedIds.isEmpty;

      emit(FolderContentLoaded(
          currentFolder: content.folder,
          subfolders: content.subfolders,
          files: content.files,
          groupedFiles: groupedFiles,
          hasMoreFiles: content.hasMoreFiles,
          totalFilesCount: content.totalFilesCount,
          currentFilter: _currentFilter,
          isSelectionMode: shouldExitSelectionMode ? false : isSelectionMode,
          selectedFileIds: cleanedSelectedIds,
          // isRefreshing defaults to false — clears the indicator
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
        groupedFiles: currentState.groupedFiles,
        totalFilesCount: currentState.totalFilesCount,
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
      final updatedGroupedFiles = DateGroupingUtil.mergeFilesIntoGroups(
        currentState.groupedFiles,
        content.files,
      );
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
        currentFolder: content.folder,
        subfolders: content.subfolders,
        files: allFiles,
        groupedFiles: updatedGroupedFiles,
        hasMoreFiles: content.hasMoreFiles,
        totalFilesCount: content.totalFilesCount,
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
      final groupedFiles = DateGroupingUtil.groupFilesByDate(content.files);
      await Future.delayed(const Duration(milliseconds: 400));
      emit(FolderContentLoaded(
          currentFolder: content.folder,
          subfolders: content.subfolders,
          files: content.files,
          groupedFiles: groupedFiles,
          hasMoreFiles: content.hasMoreFiles,
          totalFilesCount: content.totalFilesCount,
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
        emit(currentState.copyWith(selectedFileIds: newSelectedIds));
      } else {
        if (newSelectedIds.length >= kMaxFileSelection) {
          // Limit reached — signal UI without changing the selection
          emit(currentState.copyWith(
            selectedFileIds: newSelectedIds,
            selectionLimitReached: true,
          ));
        } else {
          newSelectedIds.add(event.fileId);
          emit(currentState.copyWith(selectedFileIds: newSelectedIds));
        }
      }
    }
  }

  void _onSelectAllFiles(SelectAllFiles event, Emitter<FolderContentState> emit) {
    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      final allFileIds = currentState.files.map((file) => file.id).toList();
      final limitReached = allFileIds.length > kMaxFileSelection;
      final capped = allFileIds.take(kMaxFileSelection).toSet();

      emit(currentState.copyWith(
        isSelectionMode: true,
        selectedFileIds: capped,
        selectionLimitReached: limitReached,
      ));
    }
  }

  void _onDeselectAllFiles(DeselectAllFiles event, Emitter<FolderContentState> emit) {
    if (state is FolderContentLoaded) {
      final currentState = state as FolderContentLoaded;
      emit(currentState.copyWith(selectedFileIds: {}));
    }
  }
}