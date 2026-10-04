import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/favorites/domain/use_cases/set_favorite_use_case.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';


/// Marks and unmarks favorites optimistically (viewer button and album selection).
///
/// The change shows at once here and, through [FavoritesChangedEvent], in every
/// grid. Files the server could not change go back to their previous value.
class FavoritesBloc extends Bloc<FavoritesEvent, FavoritesState> {

  final SetFavoriteUseCase setFavoriteUseCase;
  final AppEventBus eventBus;

  FavoritesBloc({required this.setFavoriteUseCase, required this.eventBus}) : super(const FavoritesState()) {
    on<SetFavorites>(_onSetFavorites);
  }

  Future<void> _onSetFavorites(SetFavorites event, Emitter<FavoritesState> emit) async {
    // Value of each file before this change, to restore it if the server fails.
    final previous = {
      for (final file in event.files) file.id: state.isFavorite(file.id, fallback: file.isFavorite),
    };
    final ids = previous.keys.toList();
    if (ids.isEmpty) return;

    emit(FavoritesState(
      overrides: {...state.overrides, for (final id in ids) id: event.favorite},
      isSaving: true,
    ));
    eventBus.fire(FavoritesChangedEvent(fileIds: ids, favorite: event.favorite));

    try {
      final result = await setFavoriteUseCase(fileIds: ids, favorite: event.favorite);
      if (result.failedIds.isNotEmpty) _restore(result.failedIds, previous, emit);
      emit(FavoritesState(
        overrides: state.overrides,
        outcome: result.allFailed
            ? FavoritesFailed(ErrorHandler.handleError(Exception('Favorite not updated')))
            : FavoritesSaved(count: result.updatedIds.length, favorite: event.favorite),
      ));
    } catch (e) {
      _restore(ids, previous, emit);
      emit(FavoritesState(overrides: state.overrides, outcome: FavoritesFailed(ErrorHandler.handleError(e))));
    }
  }

  /// Puts [ids] back to their [previous] value here and in the grids.
  void _restore(List<String> ids, Map<String, bool> previous, Emitter<FavoritesState> emit) {
    emit(FavoritesState(
      overrides: {...state.overrides, for (final id in ids) id: previous[id]!},
      isSaving: true,
    ));
    for (final value in [true, false]) {
      final restored = ids.where((id) => previous[id] == value).toList();
      if (restored.isNotEmpty) eventBus.fire(FavoritesChangedEvent(fileIds: restored, favorite: value));
    }
  }
}
