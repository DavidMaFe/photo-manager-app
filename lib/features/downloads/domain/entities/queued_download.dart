import 'package:equatable/equatable.dart';

/// A file waiting in the download queue, with the album of the gallery it goes to (null: the main one).
class QueuedDownload extends Equatable {
  final String fileId;
  final String? album;
  final int sizeBytes;

  const QueuedDownload({required this.fileId, this.album, required this.sizeBytes});

  @override
  List<Object?> get props => [fileId, album, sizeBytes];
}
