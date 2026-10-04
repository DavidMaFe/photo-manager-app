import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


class GalleryFile extends Equatable {

  final String id;
  final FileType type;
  final FileStatus status;
  final int? durationSeconds;

  /// Local time of the phone when the photo was taken. The server may not know it.
  final DateTime? capturedAt;
  final int sizeBytes;

  const GalleryFile({
    required this.id,
    required this.type,
    required this.status,
    this.durationSeconds,
    required this.capturedAt,
    this.sizeBytes = 0
  });

  bool get isImage => type == FileType.image;
  bool get isVideo => type == FileType.video;
  bool get isPending => status.isPending;
  bool get isManaged => status.isManaged;

  GalleryFile copyWith({
    String? id,
    FileType? type,
    FileStatus? status,
    int? durationSeconds,
    DateTime? capturedAt,
    int? sizeBytes
  }) {
    return GalleryFile(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      capturedAt: capturedAt ?? this.capturedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes
    );
  }

  @override
  List<Object?> get props => [id, type, status, durationSeconds, capturedAt, sizeBytes];
}
