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

  const Folder({
    required this.id,
    required this.name,
    this.parentFolderId,
    required this.path,
    required this.createdAt,
    required this.fileCount,
    required this.subfolderCount,
    this.oldestCapturedAt,
    this.newestCapturedAt
  });

  bool get isRoot => parentFolderId == null;
  bool get hasSubfolders => subfolderCount > 0;
  bool get hasFiles => fileCount > 0;
  bool get isEmpty => fileCount == 0 && subfolderCount == 0;


  @override
  List<Object?> get props => [
    id, name, parentFolderId, path, createdAt, fileCount, subfolderCount, oldestCapturedAt, newestCapturedAt
  ];
}