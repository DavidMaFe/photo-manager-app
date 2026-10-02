
import 'package:equatable/equatable.dart';

import '../../../gallery/domain/entities/gallery_file.dart';
import 'folder.dart';

class FolderContent extends Equatable {

  final Folder folder;
  final List<Folder> subfolders;
  final List<GalleryFile> files;
  final bool hasMoreFiles;
  final int totalFilesCount;

  const FolderContent({
    required this.folder,
    required this.subfolders,
    required this.files,
    required this.hasMoreFiles,
    required this.totalFilesCount
  });

  bool get hasSubfolders => subfolders.isNotEmpty;
  bool get hasFiles => files.isNotEmpty;
  bool get isEmpty => subfolders.isEmpty && files.isEmpty;

  FolderContent copyWith({
    Folder? folder,
    List<Folder>? subfolders,
    List<GalleryFile>? files,
    int? totalFilesCount,
    bool? hasMoreFiles
  }) {
    return FolderContent(
      folder: folder ?? this.folder,
      subfolders: subfolders ?? this.subfolders,
      files: files ?? this.files,
      hasMoreFiles: hasMoreFiles ?? this.hasMoreFiles,
      totalFilesCount: totalFilesCount ?? this.totalFilesCount
    );
  }

  @override
  List<Object?> get props => [folder, subfolders, files, hasMoreFiles, totalFilesCount];
}