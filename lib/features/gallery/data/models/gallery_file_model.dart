import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';

import '../../domain/entities/gallery_file.dart';


class GalleryFileModel extends GalleryFile {

  const GalleryFileModel({
    required super.id,
    required super.type,
    required super.status,
    super.durationSeconds,
    required super.capturedAt
  });

  factory GalleryFileModel.fromJson(Map<String, dynamic> json) {
    return GalleryFileModel(
      id: json['id'].toString(),
      type: FileType.fromApiString(json['type'] as String),
      status: FileStatus.fromApiString(json['status'] as String),
      durationSeconds: json['durationSecionds'] as int?,
      capturedAt: DateTime.parse(json['capturedAt'] as String)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'status': status.toApiString(),
      'durationSeconds': durationSeconds,
      'capturedAt': capturedAt.toIso8601String()
    };
  }

  factory GalleryFileModel.fromEntity(GalleryFile file) {
    return GalleryFileModel(
      id: file.id,
      type: file.type,
      status: file.status,
      durationSeconds: file.durationSeconds,
      capturedAt: file.capturedAt
    );
  }
}