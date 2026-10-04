import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
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
  final AppEventBus eventBus;

  StreamSubscription<FolderUpdatedEvent>? _folderUpdateSubscription;
  StreamSubscription<CoversChangedEvent>? _coversSubscription;
  bool _isPerformingOperation = false;

  FolderBloc({
    required this.getFoldersUseCase,
    required this.createFolderUseCase,
    required this.renameFolderUseCase,
    required this.deleteFolderUseCase,
    required this.eventBus,
  }) : super(const FolderStarting()) {
    on<LoadFolders>(_onLoadFolders);
    on<RefreshFolders>(_onRefreshFolders);
    on<CreateFolderRequested>(_onCreateFolder);
    on<RenameFolderRequested>(_onRenameFolder);
    on<DeleteFolderRequested>(_onDeleteFolder);

    // Listen to folder update events and auto-refresh
    _folderUpdateSubscription = eventBus.on<FolderUpdatedEvent>().listen((_) {
      // Don't refresh if this BLoC is performing the operation (it will refresh manually)
      if (!_isPerformingOperation) {
        add(const RefreshFolders());
      }
    });

    // Chosen covers changed: reload the album mosaics
    _coversSubscription = eventBus.on<CoversChangedEvent>().listen((_) {
      add(const RefreshFolders());
    });
  }

  @override
  Future<void> close() {
    _folderUpdateSubscription?.cancel();
    _coversSubscription?.cancel();
    return super.close();
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
    _isPerformingOperation = true;

    try {
      await createFolderUseCase(name: event.name, parentFolderId: event.parentFolderId);
      emit(const FolderOperationSuccess(operation: 'create', message: 'success'));
      add(LoadFolders(parentFolderId: event.parentFolderId));

      // Broadcast folder created event
      eventBus.fire(const FolderUpdatedEvent(updateType: FolderUpdateType.created));
      eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.folders));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    } finally {
      _isPerformingOperation = false;
    }
  }

  Future<void> _onRenameFolder(RenameFolderRequested event, Emitter<FolderState> emit) async {

    emit(const FolderOperationLoading(operation: 'rename'));
    _isPerformingOperation = true;

    try {
      await renameFolderUseCase(folderId: event.folderId, newName: event.newName);
      emit(const FolderOperationSuccess(operation: 'rename', message: 'success'));

      if (state is FolderLoaded) {
        final currentParentId = (state as FolderLoaded).currentParentId;
        add(LoadFolders(parentFolderId: currentParentId));
      } else {
        add(const LoadFolders());
      }

      // Broadcast folder renamed event
      eventBus.fire(FolderUpdatedEvent(
        affectedFolderIds: [event.folderId],
        updateType: FolderUpdateType.renamed,
      ));
      eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.folders));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    } finally {
      _isPerformingOperation = false;
    }
  }

  Future<void> _onDeleteFolder(DeleteFolderRequested event, Emitter<FolderState> emit) async {

    emit(const FolderOperationLoading(operation: 'delete'));
    _isPerformingOperation = true;

    try {
      await deleteFolderUseCase(folderId: event.folderId);
      emit(const FolderOperationSuccess(operation: 'delete', message: 'success'));

      if (state is FolderLoaded) {
        final currentParentId = (state as FolderLoaded).currentParentId;
        add(LoadFolders(parentFolderId: currentParentId));
      } else {
        add(const LoadFolders());
      }

      // Broadcast folder deleted event
      eventBus.fire(FolderUpdatedEvent(
        affectedFolderIds: [event.folderId],
        updateType: FolderUpdateType.deleted,
      ));
      eventBus.fire(const CacheInvalidationEvent(type: CacheInvalidationType.folders));
    } catch (e) {
      Failure failure = ErrorHandler.handleError(e);
      emit(FolderError(failure));
    } finally {
      _isPerformingOperation = false;
    }
  }
}