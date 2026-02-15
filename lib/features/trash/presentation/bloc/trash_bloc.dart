import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/empty_trash_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/get_trash_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/permanently_delete_files_use_case.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/restore_files_use_case.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_state.dart';

class TrashBloc extends Bloc<TrashEvent, TrashState> {
  final GetTrashFilesUseCase getTrashFilesUseCase;
  final RestoreFilesUseCase restoreFilesUseCase;
  final PermanentlyDeleteFilesUseCase permanentlyDeleteFilesUseCase;
  final EmptyTrashUseCase emptyTrashUseCase;
  final AppEventBus eventBus;

  static const int _pageSize = 50;
  static const int minimumLoadingDuration = 800; // ms

  StreamSubscription<FileUpdatedEvent>? _fileUpdateSubscription;

  TrashBloc({
    required this.getTrashFilesUseCase,
    required this.restoreFilesUseCase,
    required this.permanentlyDeleteFilesUseCase,
    required this.emptyTrashUseCase,
    required this.eventBus,
  }) : super(const TrashInitial()) {
    on<LoadTrash>(_onLoadTrash);
    on<LoadMoreTrash>(_onLoadMoreTrash);
    on<RefreshTrash>(_onRefreshTrash);
    on<EnterSelectionMode>(_onEnterSelectionMode);
    on<ExitSelectionMode>(_onExitSelectionMode);
    on<ToggleFileSelection>(_onToggleFileSelection);
    on<SelectAllFiles>(_onSelectAllFiles);
    on<ClearSelection>(_onClearSelection);
    on<RestoreSelectedFiles>(_onRestoreSelectedFiles);
    on<RestoreFiles>(_onRestoreFiles);
    on<PermanentlyDeleteSelectedFiles>(_onPermanentlyDeleteSelectedFiles);
    on<PermanentlyDeleteFiles>(_onPermanentlyDeleteFiles);
    on<EmptyTrashRequested>(_onEmptyTrashRequested);

    // Listen to file updates and auto-refresh
    _fileUpdateSubscription = eventBus.on<FileUpdatedEvent>().listen((_) {
      add(const RefreshTrash());
    });
  }

  @override
  Future<void> close() {
    _fileUpdateSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadTrash(LoadTrash event, Emitter<TrashState> emit) async {
    emit(const TrashLoading());
    final stopwatch = Stopwatch()..start();

    try {
      final result = await getTrashFilesUseCase(page: 0, pageSize: _pageSize);
      await _waitForMinimumLoading(stopwatch);

      emit(TrashLoaded(
        files: result.files,
        currentPage: result.currentPage,
        hasNext: result.hasNext,
      ));
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashError(failure));
    }
  }

  Future<void> _onLoadMoreTrash(
      LoadMoreTrash event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;
    if (!currentState.hasNext) return;

    emit(TrashLoadingMore(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
    ));

    try {
      final nextPage = currentState.currentPage + 1;
      final result =
          await getTrashFilesUseCase(page: nextPage, pageSize: _pageSize);
      final updatedFiles = [...currentState.files, ...result.files];

      await Future.delayed(const Duration(milliseconds: 400));
      emit(TrashLoaded(
        files: updatedFiles,
        currentPage: nextPage,
        hasNext: result.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(TrashError(failure));
    }
  }

  Future<void> _onRefreshTrash(
      RefreshTrash event, Emitter<TrashState> emit) async {
    bool isSelectionMode = false;
    Set<String> selectedFileIds = {};

    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      isSelectionMode = currentState.isSelectionMode;
      selectedFileIds = currentState.selectedFileIds;
    }

    emit(const TrashLoading());

    try {
      final result = await getTrashFilesUseCase(page: 0, pageSize: _pageSize);
      await Future.delayed(const Duration(milliseconds: 400));

      emit(TrashLoaded(
        files: result.files,
        currentPage: result.currentPage,
        hasNext: result.hasNext,
        isSelectionMode: isSelectionMode,
        selectedFileIds: selectedFileIds,
      ));
    } catch (e) {
      final failure = ErrorHandler.handleError(e);
      emit(TrashError(failure));
    }
  }

  void _onEnterSelectionMode(
      EnterSelectionMode event, Emitter<TrashState> emit) {
    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      emit(currentState.copyWith(isSelectionMode: true));
    }
  }

  void _onExitSelectionMode(ExitSelectionMode event, Emitter<TrashState> emit) {
    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      emit(currentState.copyWith(isSelectionMode: false, selectedFileIds: {}));
    }
  }

  void _onToggleFileSelection(
      ToggleFileSelection event, Emitter<TrashState> emit) {
    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      final newSelection = Set<String>.from(currentState.selectedFileIds);

      if (newSelection.contains(event.fileId)) {
        newSelection.remove(event.fileId);
      } else {
        newSelection.add(event.fileId);
      }

      emit(currentState.copyWith(selectedFileIds: newSelection));
    }
  }

  void _onSelectAllFiles(SelectAllFiles event, Emitter<TrashState> emit) {
    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      final allFileIds = currentState.files.map((file) => file.id).toSet();

      emit(currentState.copyWith(
        isSelectionMode: true,
        selectedFileIds: allFileIds,
      ));
    }
  }

  void _onClearSelection(ClearSelection event, Emitter<TrashState> emit) {
    if (state is TrashLoaded) {
      final currentState = state as TrashLoaded;
      emit(currentState.copyWith(selectedFileIds: {}));
    }
  }

  Future<void> _onRestoreSelectedFiles(
      RestoreSelectedFiles event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;
    if (currentState.selectedFileIds.isEmpty) return;

    emit(TrashRestoring(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      final fileIds = currentState.selectedFileIds.toList();
      await restoreFilesUseCase(fileIds);
      await _waitForMinimumLoading(stopwatch);

      // Fire event to refresh other features
      eventBus.fire(FileUpdatedEvent(
        affectedFileIds: fileIds,
        updateType: FileUpdateType.updated,
      ));

      emit(TrashRestoreSuccess(fileIds.length));

      // Auto-reload trash after successful restore
      add(const LoadTrash());
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashRestoreError(
        failure: failure,
        files: currentState.files,
        currentPage: currentState.currentPage,
        hasNext: currentState.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    }
  }

  Future<void> _onPermanentlyDeleteSelectedFiles(
      PermanentlyDeleteSelectedFiles event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;
    if (currentState.selectedFileIds.isEmpty) return;

    emit(TrashDeleting(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      final fileIds = currentState.selectedFileIds.toList();
      await permanentlyDeleteFilesUseCase(fileIds);
      await _waitForMinimumLoading(stopwatch);

      // Fire event to notify other features
      eventBus.fire(FileUpdatedEvent(
        affectedFileIds: fileIds,
        updateType: FileUpdateType.deleted,
      ));

      emit(TrashDeleteSuccess(fileIds.length));

      // Auto-reload trash after successful deletion
      add(const LoadTrash());
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashDeleteError(
        failure: failure,
        files: currentState.files,
        currentPage: currentState.currentPage,
        hasNext: currentState.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    }
  }

  Future<void> _onEmptyTrashRequested(
      EmptyTrashRequested event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;
    final currentFilesCount = currentState.files.length;

    emit(TrashDeleting(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: false,
      selectedFileIds: const {},
    ));

    final stopwatch = Stopwatch()..start();

    try {
      await emptyTrashUseCase();
      await _waitForMinimumLoading(stopwatch);

      // Fire event to notify other features
      eventBus.fire(FileUpdatedEvent(
        affectedFileIds: currentState.files.map((f) => f.id).toList(),
        updateType: FileUpdateType.deleted,
      ));

      emit(TrashDeleteSuccess(currentFilesCount));

      // Auto-reload trash (should be empty now)
      add(const LoadTrash());
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashDeleteError(
        failure: failure,
        files: currentState.files,
        currentPage: currentState.currentPage,
        hasNext: currentState.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    }
  }

  Future<void> _onRestoreFiles(
      RestoreFiles event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;

    emit(TrashRestoring(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      await restoreFilesUseCase(event.fileIds);
      await _waitForMinimumLoading(stopwatch);

      // Fire event to refresh other features
      eventBus.fire(FileUpdatedEvent(
        affectedFileIds: event.fileIds,
        updateType: FileUpdateType.updated,
      ));

      emit(TrashRestoreSuccess(event.fileIds.length));

      // Auto-reload trash after successful restore
      add(const LoadTrash());
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashRestoreError(
        failure: failure,
        files: currentState.files,
        currentPage: currentState.currentPage,
        hasNext: currentState.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    }
  }

  Future<void> _onPermanentlyDeleteFiles(
      PermanentlyDeleteFiles event, Emitter<TrashState> emit) async {
    if (state is! TrashLoaded) return;

    final currentState = state as TrashLoaded;

    emit(TrashDeleting(
      files: currentState.files,
      currentPage: currentState.currentPage,
      hasNext: currentState.hasNext,
      isSelectionMode: currentState.isSelectionMode,
      selectedFileIds: currentState.selectedFileIds,
    ));

    final stopwatch = Stopwatch()..start();

    try {
      await permanentlyDeleteFilesUseCase(event.fileIds);
      await _waitForMinimumLoading(stopwatch);

      // Fire event to notify other features
      eventBus.fire(FileUpdatedEvent(
        affectedFileIds: event.fileIds,
        updateType: FileUpdateType.deleted,
      ));

      emit(TrashDeleteSuccess(event.fileIds.length));

      // Auto-reload trash after successful deletion
      add(const LoadTrash());
    } catch (e) {
      await _waitForMinimumLoading(stopwatch);
      final failure = ErrorHandler.handleError(e);
      emit(TrashDeleteError(
        failure: failure,
        files: currentState.files,
        currentPage: currentState.currentPage,
        hasNext: currentState.hasNext,
        isSelectionMode: currentState.isSelectionMode,
        selectedFileIds: currentState.selectedFileIds,
      ));
    }
  }

  Future<void> _waitForMinimumLoading(Stopwatch stopwatch) async {
    stopwatch.stop();
    final remaining = minimumLoadingDuration - stopwatch.elapsedMilliseconds;
    if (remaining > 0) {
      await Future.delayed(Duration(milliseconds: remaining));
    }
  }
}
