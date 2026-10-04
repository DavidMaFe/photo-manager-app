import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';

class TrashFileModel extends TrashFile {
  const TrashFileModel({
    required super.id,
    required super.type,
    required super.status,
    required super.capturedAt,
    required super.deletedAt,
    required super.sizeBytes,
    super.durationSeconds,
    super.originalFolderId,
    super.originalFolderName,
  });

  factory TrashFileModel.fromJson(Map<String, dynamic> json) {
    final capturedAt = json['capturedAt'] as String?;
    return TrashFileModel(
      id: json['id'].toString(),
      type: FileType.values.firstWhere(
        (e) => e.name.toUpperCase() == json['type'].toString().toUpperCase(),
      ),
      status: FileStatus.values.firstWhere(
        (e) => e.name.toUpperCase() == json['status'].toString().toUpperCase(),
      ),
      capturedAt: capturedAt != null ? DateTime.parse(capturedAt) : null,
      deletedAt: DateTime.parse(json['deletedAt'] as String),
      sizeBytes: json['sizeBytes'] as int,
      durationSeconds: json['durationSeconds'] as int?,
      originalFolderId: json['originalFolderId']?.toString(),
      originalFolderName: json['originalFolderName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name.toUpperCase(),
      'status': status.name.toUpperCase(),
      'capturedAt': capturedAt?.toIso8601String(),
      'deletedAt': deletedAt.toIso8601String(),
      'sizeBytes': sizeBytes,
      'durationSeconds': durationSeconds,
      'originalFolderId': originalFolderId,
      'originalFolderName': originalFolderName,
    };
  }

  factory TrashFileModel.fromEntity(TrashFile file) {
    return TrashFileModel(
      id: file.id,
      type: file.type,
      status: file.status,
      capturedAt: file.capturedAt,
      deletedAt: file.deletedAt,
      sizeBytes: file.sizeBytes,
      durationSeconds: file.durationSeconds,
      originalFolderId: file.originalFolderId,
      originalFolderName: file.originalFolderName,
    );
  }
}
