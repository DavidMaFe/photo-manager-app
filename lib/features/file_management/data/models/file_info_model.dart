import 'package:photo_manager_app/features/encrypted_media/data/models/encrypted_file_ref_model.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/encrypted_file_ref.dart';
import 'package:photo_manager_app/features/encrypted_media/domain/entities/file_metadata.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';


class FileInfoModel extends FileInfo {

  /// Wrapped key and encrypted metadata of the file; the name and the MIME type are only in the metadata.
  final EncryptedFileRef? encryptedRef;

  const FileInfoModel({
    this.encryptedRef,
    required super.id,
    super.originalFilename,
    required super.type,
    required super.status,
    super.mimeType,
    super.width,
    super.height,
    super.durationSeconds,
    super.sizeBytes,
    super.capturedAt,
    super.uploadedAt,
    super.deletedAt,
    super.isFavorite,
    super.folderId,
    super.folderName,
    super.deviceId,
    super.deviceName,
  });

  /// The same info with the name and MIME type decrypted on this device.
  FileInfoModel withMetadata(FileMetadata metadata) {
    return FileInfoModel(
      encryptedRef: encryptedRef,
      id: id,
      originalFilename: metadata.name ?? originalFilename,
      type: type,
      status: status,
      mimeType: metadata.mimeType ?? mimeType,
      width: width,
      height: height,
      durationSeconds: durationSeconds,
      sizeBytes: sizeBytes,
      capturedAt: capturedAt,
      uploadedAt: uploadedAt,
      deletedAt: deletedAt,
      isFavorite: isFavorite,
      folderId: folderId,
      folderName: folderName,
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }

  factory FileInfoModel.fromJson(Map<String, dynamic> json) {
    return FileInfoModel(
      id: json['id'].toString(),
      originalFilename: json['originalFilename'] as String?,
      encryptedRef: EncryptedFileRefModel.fromJson(json),
      type: FileType.fromApiString(json['type'] as String),
      status: FileStatus.fromApiString(json['status'] as String),
      mimeType: json['mimeType'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      durationSeconds: json['durationSeconds'] as int?,
      sizeBytes: json['sizeBytes'] as int? ?? 0,
      capturedAt: _parseDate(json['capturedAt']),
      uploadedAt: _parseDate(json['uploadedAt']),
      deletedAt: _parseDate(json['deletedAt']),
      isFavorite: json['isFavorite'] as bool? ?? false,
      folderId: json['folderId']?.toString(),
      folderName: json['folderName'] as String?,
      deviceId: json['deviceId']?.toString(),
      deviceName: json['deviceName'] as String?,
    );
  }

  static DateTime? _parseDate(Object? value) => value is String ? DateTime.parse(value) : null;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalFilename': originalFilename,
      'type': type.toApiString(),
      'status': status.toApiString(),
      'mimeType': mimeType,
      'width': width,
      'height': height,
      'durationSeconds': durationSeconds,
      'sizeBytes': sizeBytes,
      'capturedAt': capturedAt?.toIso8601String(),
      'uploadedAt': uploadedAt?.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'folderId': folderId,
      'folderName': folderName,
      'deviceId': deviceId,
      'deviceName': deviceName,
    };
  }
}
