import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';


class SynchronizationModel extends Synchronization {

  const SynchronizationModel({
    required super.id,
    required super.startedAt,
    required super.status,
    required super.totalFiles,
    required super.uploadedFiles,
    required super.failedFiles
  });

  factory SynchronizationModel.fromJson(Map<String, dynamic> json) {
    return SynchronizationModel(
      id: json['syncSessionId'].toString(),
      startedAt: DateTime.parse(json['startedAt'] as String),
      status: SynchronizationStatus.fromString(json['status'] as String),
      totalFiles: json['syncFiles'] as int,
      uploadedFiles: json['uploadedFiles'] as int,
      failedFiles: json['failedFiles'] as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'syncSessionId': id,
      'startedAt': startedAt.toIso8601String(),
      'status': status.value,
      'syncFiles': totalFiles,
      'uploadedFiles': uploadedFiles,
      'failedFiles': failedFiles
    };
  }
}