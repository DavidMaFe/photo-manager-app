import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/folders/domain/entities/album_cover.dart';


enum AlbumCoversStatus { loading, ready, saving, saved, failure }


class AlbumCoversState extends Equatable {

  final AlbumCoversStatus status;
  final String folderId;

  /// Covers as loaded from the server.
  final List<AlbumCover> original;

  /// Covers in their current order (after removing and reordering).
  final List<AlbumCover> covers;

  /// Last cover removed and where it was, for "Undo".
  final (AlbumCover, int)? lastRemoved;

  /// One-shot error of the last load or save.
  final Failure? failure;

  /// Whether "Done" sent changes to the server (not only closed).
  final bool changesSaved;

  const AlbumCoversState({
    this.status = AlbumCoversStatus.loading,
    this.folderId = '',
    this.original = const [],
    this.covers = const [],
    this.lastRemoved,
    this.failure,
    this.changesSaved = false,
  });

  bool get isDirty {
    if (original.length != covers.length) return true;
    for (var i = 0; i < covers.length; i++) {
      if (original[i].fileId != covers[i].fileId) return true;
    }
    return false;
  }

  AlbumCoversState copyWith({
    AlbumCoversStatus? status,
    String? folderId,
    List<AlbumCover>? original,
    List<AlbumCover>? covers,
    (AlbumCover, int)? Function()? lastRemoved,
    Failure? failure,
    bool? changesSaved,
  }) {
    return AlbumCoversState(
      status: status ?? this.status,
      folderId: folderId ?? this.folderId,
      original: original ?? this.original,
      covers: covers ?? this.covers,
      lastRemoved: lastRemoved != null ? lastRemoved() : this.lastRemoved,
      failure: failure,
      changesSaved: changesSaved ?? this.changesSaved,
    );
  }

  @override
  List<Object?> get props => [status, folderId, original, covers, lastRemoved, failure, changesSaved];
}
