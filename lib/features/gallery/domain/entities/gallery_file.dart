import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';


class GalleryFile extends Equatable {

  final String id;
  final FileType type;
  final FileStatus status;
  final int? durationSeconds;

  /// Local time of the phone when the photo was taken. The server may not know it.
  final DateTime? capturedAt;
  final int sizeBytes;
  final bool isFavorite;

  /// The server has its 2048 px version (`MediaVariant.preview`): the viewer opens it instead of the original.
  final bool hasPreview;

  /// Albums of which this file is a cover, from the root down. Only sent inside an album.
  final List<String> coverOf;

  /// Name of the device that uploaded it; null if unknown or removed.
  final String? deviceName;

  const GalleryFile({
    required this.id,
    required this.type,
    required this.status,
    this.durationSeconds,
    required this.capturedAt,
    this.sizeBytes = 0,
    this.isFavorite = false,
    this.hasPreview = false,
    this.coverOf = const [],
    this.deviceName
  });

  bool get isImage => type == FileType.image;
  bool get isVideo => type == FileType.video;
  bool get isPending => status.isPending;
  bool get isManaged => status.isManaged;

  /// Whether this file is a cover of the album [folderId].
  bool isCoverOf(String folderId) => coverOf.contains(folderId);

  GalleryFile copyWith({
    String? id,
    FileType? type,
    FileStatus? status,
    int? durationSeconds,
    DateTime? capturedAt,
    int? sizeBytes,
    bool? isFavorite,
    bool? hasPreview,
    List<String>? coverOf,
    String? deviceName
  }) {
    return GalleryFile(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      capturedAt: capturedAt ?? this.capturedAt,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      isFavorite: isFavorite ?? this.isFavorite,
      hasPreview: hasPreview ?? this.hasPreview,
      coverOf: coverOf ?? this.coverOf,
      deviceName: deviceName ?? this.deviceName
    );
  }

  @override
  List<Object?> get props =>
      [id, type, status, durationSeconds, capturedAt, sizeBytes, isFavorite, hasPreview, coverOf, deviceName];
}
