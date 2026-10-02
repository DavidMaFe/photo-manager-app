import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';

import 'folder_model.dart';


class FolderContentModel extends FolderContent {

  const FolderContentModel({
    required super.folder,
    required super.subfolders,
    required super.files,
    required super.hasMoreFiles,
    required super.totalFilesCount
  });

  factory FolderContentModel.fromJson(Map<String, dynamic> json,
      {required int currentPage}) {

    final folder = FolderModel.fromJson(json['folderInfo'] as Map<String, dynamic>);

    final subfoldersJson = json['subfolders'] as List<dynamic>? ?? [];
    final subfolders = subfoldersJson.map((json) => FolderModel.fromJson(json as Map<String, dynamic>)).toList();

    final filesJson = json['files'] as Map<String, dynamic>? ?? {};
    final filesContent = filesJson['files'] as List<dynamic>? ?? [];
    final files = filesContent.map((json) => GalleryFileModel.fromJson(json as Map<String, dynamic>)).toList();

    final hasNext = filesJson['hasNext'] as bool? ?? false;
    final totalCount = filesJson['totalCount'] as int? ?? 0;

    return FolderContentModel(
      folder: folder,
      subfolders: subfolders,
      files: files,
      hasMoreFiles: hasNext,
      totalFilesCount: totalCount
    );
  }

  FolderContent toEntity() {
    return this;
  }

  factory FolderContentModel.fromEntity(FolderContent contents) {
    return FolderContentModel(
      folder: contents.folder,
      subfolders: contents.subfolders,
      files: contents.files,
      hasMoreFiles: contents.hasMoreFiles,
      totalFilesCount: contents.totalFilesCount
    );
  }
}