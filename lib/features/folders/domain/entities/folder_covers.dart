import 'package:equatable/equatable.dart';

import 'album_cover.dart';


/// Covers of one album after a change.
class FolderCovers extends Equatable {

  final String folderId;
  final List<AlbumCover> covers;

  const FolderCovers({required this.folderId, required this.covers});

  @override
  List<Object?> get props => [folderId, covers];
}
