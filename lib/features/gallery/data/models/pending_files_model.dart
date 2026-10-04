import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';


class PendingFilesModel extends PendingFiles {

  const PendingFilesModel({required super.fileIds, required super.totalSizeBytes});

  factory PendingFilesModel.fromJson(Map<String, dynamic> json) {
    final ids = json['fileIds'] as List<dynamic>? ?? const [];
    return PendingFilesModel(
      fileIds: ids.map((id) => id.toString()).toList(),
      totalSizeBytes: json['totalSizeBytes'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'fileIds': fileIds, 'totalSizeBytes': totalSizeBytes};
  }
}
