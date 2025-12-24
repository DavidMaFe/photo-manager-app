import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';


class SyncResultModel extends SyncResult {

  SyncResultModel({
    required super.totalFiles,
    required super.uploadedFiles,
    required super.failedFiles,
  });

  factory SyncResultModel.fromJson(Map<String, dynamic> json) {
    return SyncResultModel(
      totalFiles: json['totalFiles'] as int,
      uploadedFiles: json['filesUploaded'] as int,
      failedFiles: json['filesFailed'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalFiles': totalFiles,
      'filesUploaded': uploadedFiles,
      'filesFailed': failedFiles,
    };
  }

  factory SyncResultModel.fromEntity(SyncResult result) {
    return SyncResultModel(
      totalFiles: result.totalFiles,
      uploadedFiles: result.uploadedFiles,
      failedFiles: result.failedFiles,
    );
  }
}