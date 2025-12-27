import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


class GalleryFile extends Equatable {

  final String id;
  final FileType type;
  final FileStatus status;
  final int? durationSeconds;
  final DateTime capturedAt;

  const GalleryFile({
    required this.id,
    required this.type,
    required this.status,
    this.durationSeconds,
    required this.capturedAt
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
    DateTime? capturedAt
  }) {
    return GalleryFile(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      capturedAt: capturedAt ?? this.capturedAt
    );
  }

  @override
  List<Object?> get props => [id, type, status, durationSeconds, capturedAt];
}