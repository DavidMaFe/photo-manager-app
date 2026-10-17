import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';

class RemoteMediaFileModel extends RemoteMediaFile {
  const RemoteMediaFileModel({required super.id, required super.type, required super.sizeBytes, super.folderId});

  factory RemoteMediaFileModel.fromJson(Map<String, dynamic> json) => RemoteMediaFileModel(
        id: json['id'].toString(),
        type: FileType.fromApiString(json['type'] as String),
        sizeBytes: json['sizeBytes'] as int? ?? 0,
        folderId: json['folderId']?.toString(),
      );
}
