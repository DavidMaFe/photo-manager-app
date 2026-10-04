import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

class TrashFile extends GalleryFile {
  final DateTime deletedAt;
  final String? originalFolderId;
  final String? originalFolderName;

  const TrashFile({
    required super.id,
    required super.type,
    required super.status,
    required super.capturedAt,
    required this.deletedAt,
    required super.sizeBytes,
    super.durationSeconds,
    super.isFavorite,
    this.originalFolderId,
    this.originalFolderName,
  });

  /// Calculate days until permanent deletion (30 days from deletion date)
  int get daysUntilPermanentDeletion {
    final daysSinceDeletion = DateTime.now().difference(deletedAt).inDays;
    final daysRemaining = 30 - daysSinceDeletion;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Check if file will be automatically deleted soon (less than 7 days)
  bool get isDeletionImminent => daysUntilPermanentDeletion <= 7;

  /// Get human-readable file size
  String get formattedSize {
    if (sizeBytes < 1024) {
      return '$sizeBytes B';
    } else if (sizeBytes < 1024 * 1024) {
      final kb = (sizeBytes / 1024).toStringAsFixed(1);
      return '$kb KB';
    } else if (sizeBytes < 1024 * 1024 * 1024) {
      final mb = (sizeBytes / (1024 * 1024)).toStringAsFixed(1);
      return '$mb MB';
    } else {
      final gb = (sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2);
      return '$gb GB';
    }
  }

  /// Check if file has original folder information
  bool get hasOriginalFolder =>
      originalFolderId != null && originalFolderName != null;

  @override
  List<Object?> get props => [
        ...super.props,
        deletedAt,
        originalFolderId,
        originalFolderName,
      ];

  @override
  TrashFile copyWith({
    String? id,
    FileType? type,
    FileStatus? status,
    int? durationSeconds,
    DateTime? capturedAt,
    DateTime? deletedAt,
    String? originalFolderId,
    String? originalFolderName,
    int? sizeBytes,
    bool? isFavorite,
    // Trashed files are never album covers: accepted only to match GalleryFile.copyWith.
    List<String>? coverOf,
  }) {
    return TrashFile(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      capturedAt: capturedAt ?? this.capturedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      originalFolderId: originalFolderId ?? this.originalFolderId,
      originalFolderName: originalFolderName ?? this.originalFolderName,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
