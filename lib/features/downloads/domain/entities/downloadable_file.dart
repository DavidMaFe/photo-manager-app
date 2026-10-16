import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';

/// What saving a file into the gallery needs from the server besides its content.
class DownloadableFile extends Equatable {
  final String id;
  final FileType type;

  /// Local time of the phone when it was taken: the date the gallery shows.
  final DateTime? capturedAt;

  const DownloadableFile({required this.id, required this.type, this.capturedAt});

  bool get isVideo => type == FileType.video;

  @override
  List<Object?> get props => [id, type, capturedAt];
}
