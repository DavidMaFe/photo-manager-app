import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/get_album_covers_use_case.dart';
import 'package:photo_manager_app/features/folders/domain/use_cases/set_album_covers_use_case.dart';

import 'album_covers_state.dart';


/// "Cover of {album}" sheet: remove (with undo) and reorder the chosen covers,
/// and save the final order.
class AlbumCoversCubit extends Cubit<AlbumCoversState> {

  final GetAlbumCoversUseCase getAlbumCoversUseCase;
  final SetAlbumCoversUseCase setAlbumCoversUseCase;
  final AppEventBus eventBus;

  AlbumCoversCubit({
    required this.getAlbumCoversUseCase,
    required this.setAlbumCoversUseCase,
    required this.eventBus,
  }) : super(const AlbumCoversState());

  Future<void> load(String folderId) async {
    emit(AlbumCoversState(folderId: folderId));
    try {
      final covers = await getAlbumCoversUseCase(folderId);
      emit(state.copyWith(status: AlbumCoversStatus.ready, original: covers, covers: covers));
    } catch (e) {
      emit(state.copyWith(status: AlbumCoversStatus.failure, failure: ErrorHandler.handleError(e)));
    }
  }

  void remove(String fileId) {
    final index = state.covers.indexWhere((cover) => cover.fileId == fileId);
    if (index < 0) return;
    emit(state.copyWith(
      covers: [...state.covers]..removeAt(index),
      lastRemoved: () => (state.covers[index], index),
    ));
  }

  /// Puts the last removed cover back where it was.
  void undoRemove() {
    final removed = state.lastRemoved;
    if (removed == null) return;
    final (cover, index) = removed;
    final covers = [...state.covers]..insert(index.clamp(0, state.covers.length), cover);
    emit(state.copyWith(covers: covers, lastRemoved: () => null));
  }

  /// Moves a cover like [ReorderableListView.onReorder] does ([newIndex] counts the moved item).
  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= state.covers.length) return;
    final target = (newIndex > oldIndex ? newIndex - 1 : newIndex).clamp(0, state.covers.length - 1);
    if (target == oldIndex) return;
    final covers = [...state.covers];
    covers.insert(target, covers.removeAt(oldIndex));
    emit(state.copyWith(covers: covers, lastRemoved: () => null));
  }

  /// Saves the order if it changed; otherwise only closes.
  Future<void> save() async {
    if (state.status != AlbumCoversStatus.ready) return;
    if (!state.isDirty) {
      emit(state.copyWith(status: AlbumCoversStatus.saved));
      return;
    }
    emit(state.copyWith(status: AlbumCoversStatus.saving));
    try {
      final covers = await setAlbumCoversUseCase(
        folderId: state.folderId,
        orderedFileIds: [for (final cover in state.covers) cover.fileId],
      );
      eventBus.fire(CoversChangedEvent(folderIds: [state.folderId]));
      emit(state.copyWith(
        status: AlbumCoversStatus.saved,
        original: covers,
        covers: covers,
        lastRemoved: () => null,
        changesSaved: true,
      ));
    } catch (e) {
      emit(state.copyWith(status: AlbumCoversStatus.ready, failure: ErrorHandler.handleError(e)));
    }
  }
}
