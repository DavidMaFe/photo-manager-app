import '../../domain/entities/folder.dart';


class FolderModel extends Folder {

  const FolderModel({
    required super.id,
    required super.name,
    super.parentFolderId,
    required super.path,
    required super.createdAt,
    required super.fileCount,
    required super.subfolderCount
  });

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      parentFolderId: json['parentFolderId']?.toString(),
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      fileCount: json['filesQuantity'] as int? ?? 0,
      subfolderCount: json['subfolderCount'] as int? ?? 0
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'parentFolderId': parentFolderId,
      'path': path,
      'createdAt': createdAt,
      'filesQuantity': fileCount,
      'subfolderCount': subfolderCount
    };
  }

  Folder toEntity() {
    return this;
  }

  factory FolderModel.fromEntity(Folder folder) {
    return FolderModel(
      id: folder.id,
      name: folder.name,
      parentFolderId: folder.parentFolderId,
      path: folder.path,
      createdAt: folder.createdAt,
      fileCount: folder.fileCount,
      subfolderCount: folder.subfolderCount
    );
  }
}