import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';


class SyncFileModel extends SyncFile {

  SyncFileModel({
    required super.localId,
    required super.devicePath,
    required super.hash,
    required super.fileName,
    required super.sizeBytes,
    required super.capturedAt,
    required super.mimeType,
    super.width,
    super.height,
    super.durationSeconds
  });

  factory SyncFileModel.fromJson(Map<String, dynamic> json) {
    return SyncFileModel(
      localId: '',
      devicePath: json['path'] as String,
      hash: json['hash'] as String,
      fileName: json['name'] as String,
      sizeBytes: json['fileSizeBytes'] as int,
      capturedAt: DateTime.parse(json['capturedAt'] as String),
      mimeType: json['mimeType'] as String,
      width: json['width'] as int?,
      height: json['height'] as int?,
      durationSeconds: json['durationSeconds'] as int?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localId': localId,
      'path': devicePath,
      'hash': hash,
      'name': fileName,
      'fileSizeBytes': sizeBytes,
      'capturedAt': capturedAt,
      'mimeType': mimeType,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (durationSeconds != null) 'durationSeconds': durationSeconds
    };
  }

  factory SyncFileModel.fromEntity(SyncFile file) {
    return SyncFileModel(
      localId: file.localId,
      devicePath: file.devicePath,
      hash: file.hash,
      fileName: file.fileName,
      sizeBytes: file.sizeBytes,
      capturedAt: file.capturedAt,
      mimeType: file.mimeType,
      width: file.width,
      height: file.height,
      durationSeconds: file.durationSeconds
    );
  }
}