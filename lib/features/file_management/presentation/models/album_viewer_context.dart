import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';


/// The viewer was opened from an album: its path goes in the header and the
/// bar offers "Cover" and "Move".
class AlbumViewerContext extends Equatable {

  final String folderId;
  final String folderName;

  /// «Vacaciones 2024 › Playa › Atardeceres».
  final String path;

  /// Names of the albums known here (the album and its parent), to name the
  /// album a photo is a cover of.
  final Map<String, String> albumNames;

  const AlbumViewerContext({
    required this.folderId,
    required this.folderName,
    required this.path,
    this.albumNames = const {},
  });

  /// The server path is built from the album names, root first ("/Trips/Japan").
  factory AlbumViewerContext.fromFolder(Folder folder) {
    final parts = folder.path.split('/').where((part) => part.isNotEmpty).toList();
    final parentId = folder.parentFolderId;
    return AlbumViewerContext(
      folderId: folder.id,
      folderName: folder.name,
      path: parts.isEmpty ? folder.name : parts.join(' › '),
      albumNames: {
        folder.id: folder.name,
        if (parentId != null && parts.length >= 2) parentId: parts[parts.length - 2],
      },
    );
  }

  String? nameOf(String folderId) => albumNames[folderId];

  @override
  List<Object?> get props => [folderId, folderName, path, albumNames];
}
