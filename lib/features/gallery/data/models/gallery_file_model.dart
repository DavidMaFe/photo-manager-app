import 'package:photo_manager_app/features/encrypted_media/data/models/encrypted_file_ref_model.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';

import '../../domain/entities/gallery_file.dart';


class GalleryFileModel extends GalleryFile {

  /// Wrapped key of the file, for the key directory of the app (not part of the entity).
  final EncryptedFileRef? encryptedRef;

  const GalleryFileModel({
    this.encryptedRef,
    required super.id,
    required super.type,
    required super.status,
    super.durationSeconds,
    required super.capturedAt,
    super.sizeBytes,
    super.isFavorite,
    super.coverOf
  });

  factory GalleryFileModel.fromJson(Map<String, dynamic> json) {
    final capturedAt = json['capturedAt'] as String?;
    return GalleryFileModel(
      id: json['id'].toString(),
      type: FileType.fromApiString(json['type'] as String),
      status: FileStatus.fromApiString(json['status'] as String),
      durationSeconds: json['durationSeconds'] as int?,
      capturedAt: capturedAt != null ? DateTime.parse(capturedAt) : null,
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      isFavorite: json['isFavorite'] as bool? ?? false,
      coverOf: (json['coverOf'] as List<dynamic>? ?? const []).map((id) => id.toString()).toList(),
      encryptedRef: EncryptedFileRefModel.fromJson(json)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toApiString(),
      'status': status.toApiString(),
      'durationSeconds': durationSeconds,
      'capturedAt': capturedAt?.toIso8601String(),
      'sizeBytes': sizeBytes,
      'isFavorite': isFavorite,
      'coverOf': coverOf
    };
  }

  factory GalleryFileModel.fromEntity(GalleryFile file) {
    return GalleryFileModel(
      id: file.id,
      type: file.type,
      status: file.status,
      durationSeconds: file.durationSeconds,
      capturedAt: file.capturedAt,
      sizeBytes: file.sizeBytes,
      isFavorite: file.isFavorite,
      coverOf: file.coverOf
    );
  }
}
