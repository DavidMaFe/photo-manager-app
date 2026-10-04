import 'package:equatable/equatable.dart';


/// A photo chosen as cover of an album, and where it is inside the album.
class AlbumCover extends Equatable {

  final String fileId;

  /// 0 is the main (big) cover.
  final int position;
  final String sourceFolderId;
  final String sourceFolderName;

  /// Folder names from the album (excluded) down to the photo's folder;
  /// empty when the photo is directly in the album.
  final List<String> sourceFolderPath;

  const AlbumCover({
    required this.fileId,
    required this.position,
    required this.sourceFolderId,
    required this.sourceFolderName,
    this.sourceFolderPath = const [],
  });

  bool get isFromThisAlbum => sourceFolderPath.isEmpty;

  @override
  List<Object?> get props => [fileId, position, sourceFolderId, sourceFolderName, sourceFolderPath];
}
