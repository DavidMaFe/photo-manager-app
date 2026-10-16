import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';

/// A file of the server, in the light form the device compares with its gallery (GET /api/file/ids/).
class RemoteMediaFile extends Equatable {
  final String id;
  final FileType type;

  /// Encrypted size of the original, close to the size it takes in the gallery.
  final int sizeBytes;
  final String? folderId;

  const RemoteMediaFile({required this.id, required this.type, required this.sizeBytes, this.folderId});

  @override
  List<Object?> get props => [id, type, sizeBytes, folderId];
}
