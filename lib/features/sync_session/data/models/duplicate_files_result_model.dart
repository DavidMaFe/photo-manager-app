import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';


class DuplicateFilesResultModel extends DuplicateFilesResult {

  DuplicateFilesResultModel({
    required super.filesToUpload,
    required super.duplicatesCount,
    required super.totalFiles
  });

  factory DuplicateFilesResultModel.fromJson(Map<String, dynamic> json) {
    return DuplicateFilesResultModel(
      filesToUpload: (json['filesToUpload'] as List<dynamic>)
          .map((hash) => hash as String)
          .toList(),
      duplicatesCount: json['duplicatedFiles'] as int,
      totalFiles: json['totalFilesToUpload'] as int
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filesToUpload': filesToUpload,
      'duplicatedFiles': duplicatesCount,
      'totalFilesToUpload': totalFiles
    };
  }

  factory DuplicateFilesResultModel.fromEntity(DuplicateFilesResult result) {
    return DuplicateFilesResultModel(
      filesToUpload: result.filesToUpload,
      duplicatesCount: result.duplicatesCount,
      totalFiles: result.totalFiles
    );
  }
}