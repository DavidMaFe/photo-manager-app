import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';

import 'album_cover.dart';


/// An album a photo can be a cover of: the album that contains it or one of its ancestors.
class CoverTarget extends Equatable {

  final String folderId;
  final String name;

  /// 0 for a root album.
  final int depth;

  /// Whether the photo is directly in this album (not in a sub-album).
  final bool containsDirectly;

  /// Current covers of the album, in order.
  final List<AlbumCover> covers;

  const CoverTarget({
    required this.folderId,
    required this.name,
    required this.depth,
    required this.containsDirectly,
    this.covers = const [],
  });

  bool get isFull => covers.length >= kMaxAlbumCovers;
  bool hasCover(String fileId) => covers.any((cover) => cover.fileId == fileId);

  @override
  List<Object?> get props => [folderId, name, depth, containsDirectly, covers];
}
