import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/utils/date_grouping_util.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_pending_file_ids_use_case.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_event.dart';
import 'package:photo_manager_app/features/gallery/presentation/bloc/gallery_state.dart';

import '../../domain/enums/file_filter.dart';


class GalleryBloc extends Bloc<GalleryEvent, GalleryState> {

  final GetFilesUseCase getFilesUseCase;
  final GetPendingFileIdsUseCase getPendingFileIdsUseCase;
  final AppEventBus eventBus;
  static const int _pageSize = 50;

  /// Time the thumbnail of a file unmarked in the "Favorites" filter takes to fade out.
  static const Duration unfavoritedExitDuration = Duration(milliseconds: 250);

  StreamSubscription<FileUpdatedEvent>? _fileUpdateSubscription;
  StreamSubscription<FolderUpdatedEvent>? _folderUpdateSubscription;
  StreamSubscription<SyncCompletedEvent>? _syncCompletedSubscription;
  StreamSubscription<FavoritesChangedEvent>? _favoritesSubscription;

  GalleryBloc({
    required this.getFilesUseCase,
    required this.getPendingFileIdsUseCase,
    required this.eventBus,
  }) : super(const GalleryStarting()) {
    on<LoadGallery>(_onLoadGallery);
    on<LoadMoreFiles>(_onLoadMoreFiles);
    on<RefreshGallery>(_onRefreshGallery);
    on<EnterSelectionMode>(_onEnterSelectionMode);
    on<ExitSelectionMode>(_onExitSelectionMode);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<SelectAllFiles>(_onSelectAllFiles);
    on<ClearSelection>(_onClearSelection);
    on<ReviewPendingFiles>(_onReviewPendingFiles);
    on<FavoritesChanged>(_onFavoritesChanged);
    on<RemoveUnfavoritedFiles>(_onRemoveUnfavoritedFiles);

    // Listen to file updates and auto-refresh
    _fileUpdateSubscription = eventBus.on<FileUpdatedEvent>().listen((_) {
      add(const RefreshGallery());
    });

    // Listen to folder updates (files might have been moved to folders)
    _folderUpdateSubscription = eventBus.on<FolderUpdatedEvent>().listen((_) {
      add(const RefreshGallery());
    });

    // Listen to sync completion (new files added)
    _syncCompletedSubscription = eventBus.on<SyncCompletedEvent>().listen((_) {
      add(const RefreshGallery());
    });

    // Favorites marked elsewhere: update the hearts in place, without reloading
    _favoritesSubscription = eventBus.on<FavoritesChangedEvent>().listen((event) {
      add(FavoritesChanged(fileIds: event.fileIds, favorite: event.favorite));
    });
  }

  @override
  Future<void> close() {
    _fileUpdateSubscription?.cancel();
    _folderUpdateSubscription?.cancel();
    _syncCompletedSubscription?.cancel();
    _favoritesSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadGallery(LoadGallery event, Emitter<GalleryState> emit) async {

    emit(GalleryLoading(filter: event.filter));

    try {

      final result = await getFilesUseCase(page: 0, pageSize: _pageSize, filter: event.filter);
      final groupedFiles = DateGroupingUtil.groupFilesByDate(result.files);
      await Future.delayed(const Duration(milliseconds: 400));
      emit(GalleryLoaded(
        files: result.files,
        groupedFiles: groupedFiles,
        isSelectionMode: false,
        selectedFileIds: const {},
        hasNext: result.hasNext,
        currentPage: result.currentPage,
        totalFilesCount: result.totalFilesCount,
        totalPendingCount: result.totalPendingCount,
        filter: event.filter
      ));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  Future<void> _onLoadMoreFiles(LoadMoreFiles event, Emitter<GalleryState> emit) async {

    if (state is! GalleryLoaded) return;

    final currentState = state as GalleryLoaded;
    if(!currentState.hasNext) return;

    emit(GalleryLoadingMore(
      files: currentState.files,
      groupedFiles: currentState.groupedFiles,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
      currentPage: currentState.currentPage,
      totalFilesCount: currentState.totalFilesCount,
      totalPendingCount: currentState.totalPendingCount,
      filter:  currentState.filter
    ));

    try {

      final nextPage = currentState.currentPage + 1;
      final result = await getFilesUseCase(page: nextPage, pageSize: _pageSize, filter: currentState.filter);
      final updatedFiles = [
        ...currentState.files,
        ...result.files
      ];
      final updatedGroupedFiles = DateGroupingUtil.mergeFilesIntoGroups(
        currentState.groupedFiles,
        result.files,
      );

      await Future.delayed(const Duration(milliseconds: 400));
      emit(GalleryLoaded(
        files: updatedFiles,
        groupedFiles: updatedGroupedFiles,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
        hasNext: result.hasNext,
        currentPage: nextPage,
        totalFilesCount: result.totalFilesCount,
        totalPendingCount: result.totalPendingCount,
        filter: currentState.filter
      ));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  Future<void> _onRefreshGallery(RefreshGallery event, Emitter<GalleryState> emit) async {

    FileFilter currentFilter = FileFilter.all;
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};

    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      currentFilter = currentState.filter;
      isSelectionMode = currentState.isSelectionMode;
      selectedFileIds = currentState.selectedFileIds;
      // Signal refresh in progress — keeps FilesGrid alive so scroll position is preserved
      emit(currentState.copyWith(isRefreshing: true));
    } else if (state is GalleryLoadingMore) {
      final currentState = state as GalleryLoadingMore;
      currentFilter = currentState.filter;
      isSelectionMode = currentState.isSelectionMode;
      selectedFileIds = currentState.selectedFileIds;
      // Grid is already visible in GalleryLoadingMore — no intermediate emit needed
    } else {
      // No content yet (error / starting state) — fall back to full loading spinner
      emit(GalleryLoading(filter: currentFilter));
    }

    try {

      final result = await getFilesUseCase(page: 0, pageSize: _pageSize, filter: currentFilter);
      final groupedFiles = DateGroupingUtil.groupFilesByDate(result.files);

      // Clean up selectedFileIds - remove any IDs that no longer exist in the file list
      final currentFileIds = result.files.map((f) => f.id).toSet();
      final cleanedSelectedIds = selectedFileIds.where((id) => currentFileIds.contains(id)).toSet();

      // Exit selection mode if no files remain selected
      final shouldExitSelectionMode = isSelectionMode && cleanedSelectedIds.isEmpty;

      emit(GalleryLoaded(
        files: result.files,
        groupedFiles: groupedFiles,
        isSelectionMode: shouldExitSelectionMode ? false : isSelectionMode,
        selectedFileIds: cleanedSelectedIds,
        hasNext: result.hasNext,
        currentPage: result.currentPage,
        totalFilesCount: result.totalFilesCount,
        totalPendingCount: result.totalPendingCount,
        filter: currentFilter,
        // isRefreshing defaults to false — clears the indicator
      ));

    } catch(e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  /// Selects every pending file (one call, without the manual selection limit),
  /// loads the first page of them for the grid and flags the review.
  Future<void> _onReviewPendingFiles(ReviewPendingFiles event, Emitter<GalleryState> emit) async {

    emit(const GalleryLoading(filter: FileFilter.pending));

    try {
      final pending = await getPendingFileIdsUseCase();
      final result = await getFilesUseCase(page: 0, pageSize: _pageSize, filter: FileFilter.pending);

      final selected = pending.fileIds.toSet();

      emit(GalleryLoaded(
        files: result.files,
        groupedFiles: DateGroupingUtil.groupFilesByDate(result.files),
        isSelectionMode: selected.isNotEmpty,
        selectedFileIds: selected,
        hasNext: result.hasNext,
        currentPage: result.currentPage,
        totalFilesCount: result.totalFilesCount,
        totalPendingCount: result.totalPendingCount,
        filter: FileFilter.pending,
        reviewRequested: selected.isNotEmpty,
        reviewSizeBytes: pending.totalSizeBytes,
      ));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(GalleryError(failure));
    }
  }

  /// Updates the hearts of the loaded files. In the "Favorites" filter an
  /// unmarked file fades out and then leaves the grid, and one marked again
  /// reloads it.
  void _onFavoritesChanged(FavoritesChanged event, Emitter<GalleryState> emit) {
    final currentState = state;
    if (currentState is! GalleryLoaded) return;

    final ids = event.fileIds.toSet();
    final onlyFavorites = currentState.filter.onlyFavorites;

    if (!currentState.files.any((file) => ids.contains(file.id))) {
      // A favorite that is not loaded yet in its own filter: reload to show it.
      if (onlyFavorites && event.favorite) add(const RefreshGallery());
      return;
    }

    final files = [
      for (final file in currentState.files)
        ids.contains(file.id) ? file.copyWith(isFavorite: event.favorite) : file,
    ];
    emit(currentState.copyWith(files: files, groupedFiles: DateGroupingUtil.groupFilesByDate(files)));

    // The grid fades the unmarked thumbnails out first (see FilesGrid.fadeOutUnfavorited).
    if (onlyFavorites && !event.favorite) {
      Future.delayed(unfavoritedExitDuration, () {
        if (!isClosed) add(const RemoveUnfavoritedFiles());
      });
    }
  }

  /// Removes the files that are still unmarked (a failed change may have marked them again).
  void _onRemoveUnfavoritedFiles(RemoveUnfavoritedFiles event, Emitter<GalleryState> emit) {
    final currentState = state;
    if (currentState is! GalleryLoaded || !currentState.filter.onlyFavorites) return;

    final removedIds = {for (final file in currentState.files) if (!file.isFavorite) file.id};
    if (removedIds.isEmpty) return;

    final files = currentState.files.where((file) => file.isFavorite).toList();
    emit(currentState.copyWith(
      files: files,
      groupedFiles: DateGroupingUtil.groupFilesByDate(files),
      totalFilesCount: currentState.totalFilesCount - removedIds.length,
      selectedFileIds: currentState.selectedFileIds.difference(removedIds),
    ));
  }

  void _onEnterSelectionMode(EnterSelectionMode event, Emitter<GalleryState> emit) {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      emit(currentState.copyWith(isSelectionMode: true));
    }
  }

  void _onExitSelectionMode(ExitSelectionMode event, Emitter<GalleryState> emit) {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      emit(currentState.copyWith(isSelectionMode: false, selectedFileIds: {}));
    }
  }

  void _onToggleFileSelection(ToggleFileSelection event, Emitter<GalleryState> emit) {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      final newSelection = Set<String>.from(currentState.selectedFileIds);

      if (newSelection.contains(event.fileId)) {
        newSelection.remove(event.fileId);
        emit(currentState.copyWith(selectedFileIds: newSelection));
      } else {
        if (newSelection.length >= kMaxFileSelection) {
          // Limit reached — signal UI without changing the selection
          emit(currentState.copyWith(
            selectedFileIds: newSelection,
            selectionLimitReached: true,
          ));
        } else {
          newSelection.add(event.fileId);
          emit(currentState.copyWith(selectedFileIds: newSelection));
        }
      }
    }
  }

  void _onSelectAllFiles(SelectAllFiles event, Emitter<GalleryState> emit) {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
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

  void _onClearSelection(ClearSelection event, Emitter<GalleryState> emit) {
    if (state is GalleryLoaded) {
      final currentState = state as GalleryLoaded;
      emit(currentState.copyWith(selectedFileIds: {}));
    }
  }
}