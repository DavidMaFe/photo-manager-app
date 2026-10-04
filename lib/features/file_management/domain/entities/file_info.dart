import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


/// Every property of a file, for the properties sheet.
/// Nullable fields are unknown or do not apply (e.g. no device for web uploads).
class FileInfo extends Equatable {

  final String id;
  final String? originalFilename;
  final FileType type;
  final FileStatus status;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? durationSeconds;
  final int sizeBytes;
  final DateTime? capturedAt;
  final DateTime? uploadedAt;
  final DateTime? deletedAt;
  final bool isFavorite;
  final String? folderId;
  final String? folderName;
  final String? deviceId;
  final String? deviceName;

  const FileInfo({
    required this.id,
    this.originalFilename,
    required this.type,
    required this.status,
    this.mimeType,
    this.width,
    this.height,
    this.durationSeconds,
    this.sizeBytes = 0,
    this.capturedAt,
    this.uploadedAt,
    this.deletedAt,
    this.isFavorite = false,
    this.folderId,
    this.folderName,
    this.deviceId,
    this.deviceName,
  });

  bool get hasDimensions => width != null && height != null && width! > 0 && height! > 0;

  @override
  List<Object?> get props => [
    id, originalFilename, type, status, mimeType, width, height, durationSeconds, sizeBytes,
    capturedAt, uploadedAt, deletedAt, isFavorite, folderId, folderName, deviceId, deviceName
  ];
}
