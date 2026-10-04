import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';


/// Result of the last change, to show its snackbar once.
sealed class FavoritesOutcome extends Equatable {
  const FavoritesOutcome();
}

class FavoritesSaved extends FavoritesOutcome {
  final int count;
  final bool favorite;

  const FavoritesSaved({required this.count, required this.favorite});

  @override
  List<Object?> get props => [count, favorite];
}

class FavoritesFailed extends FavoritesOutcome {
  final Failure failure;

  const FavoritesFailed(this.failure);

  @override
  List<Object?> get props => [failure];
}


class FavoritesState extends Equatable {

  /// Favorite value of the files changed here, over what the files say.
  final Map<String, bool> overrides;

  /// Whether a change is waiting for the server.
  final bool isSaving;

  /// One-shot: the outcome of the change that just finished.
  final FavoritesOutcome? outcome;

  const FavoritesState({this.overrides = const {}, this.isSaving = false, this.outcome});

  /// Current favorite value of a file.
  bool isFavorite(String fileId, {required bool fallback}) => overrides[fileId] ?? fallback;

  @override
  List<Object?> get props => [overrides, isSaving, outcome];
}
