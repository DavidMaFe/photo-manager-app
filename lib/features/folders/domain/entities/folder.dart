import 'package:equatable/equatable.dart';


class Folder extends Equatable {

  final String id;
  final String name;
  final String? parentFolderId;
  final String path;
  final DateTime createdAt;
  final int fileCount;
  final int subfolderCount;

  /// Capture dates of the oldest and newest file of the album and its sub-albums.
  final DateTime? oldestCapturedAt;
  final DateTime? newestCapturedAt;

  /// Covers chosen by the user, in order (0–3). The first one is the big tile.
  final List<String> coverFileIds;

  /// Most recent photos of the album tree, only while no cover is chosen.
  final List<String> fallbackCoverFileIds;

  const Folder({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.path,
    required this.createdAt,
    required this.fileCount,
    required this.subfolderCount,
    this.oldestCapturedAt,
    this.newestCapturedAt,
    this.coverFileIds = const [],
    this.fallbackCoverFileIds = const []
  });

  bool get isRoot => parentFolderId == null;
  bool get hasSubfolders => subfolderCount > 0;
  bool get hasFiles => fileCount > 0;
  bool get isEmpty => fileCount == 0 && subfolderCount == 0;
  bool get hasCustomCovers => coverFileIds.isNotEmpty;

  /// Files of the mosaic: the chosen covers, or the recent photos without them.
  List<String> get mosaicFileIds => hasCustomCovers ? coverFileIds : fallbackCoverFileIds;


  @override
  List<Object?> get props => [
    id, name, parentFolderId, path, createdAt, fileCount, subfolderCount, oldestCapturedAt, newestCapturedAt,
    coverFileIds, fallbackCoverFileIds
  ];
}