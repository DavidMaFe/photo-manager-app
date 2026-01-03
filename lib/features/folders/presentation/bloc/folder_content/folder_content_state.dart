import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

import '../../../../../core/errors/base/failures.dart';
import '../../../domain/entities/folder.dart';


abstract class FolderContentState extends Equatable {
  const FolderContentState();

  @override
  List<Object?> get props => [];
}


class FolderContentStarting extends FolderContentState {
  const FolderContentStarting();
}


class FolderContentLoading extends FolderContentState {

  final Folder? previousFolder;
  final List<Folder>? previousSubfolders;

  const FolderContentLoading({this.previousFolder, this.previousSubfolders});

  @override
  List<Object?> get props => [previousFolder, previousSubfolders];
}


class FolderContentLoaded extends FolderContentState {

  final Folder currentFolder;
  final List<Folder> subfolders;
  final List<GalleryFile> files;
  final bool hasMoreFiles;
  final FileFilter currentFilter;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;

  const FolderContentLoaded({
    required this.currentFolder,
    required this.subfolders,
    required this.files,
    required this.hasMoreFiles,
    this.currentFilter = FileFilter.all,
    this.isSelectionMode = false,
    this.selectedFileIds = const {}
  });

  @override
  List<Object?> get props => [currentFolder, subfolders, files, hasMoreFiles,
    currentFilter, isSelectionMode, selectedFileIds];

  FolderContentLoaded copyWith({
    Folder? currentFolder,
    List<Folder>? subfolders,
    List<GalleryFile>? files,
    int? totalFiles,
    bool? hasMoreFiles,
    FileFilter? currentFilter,
    bool? isSelectionMode,
    Set<String>? selectedFileIds
  }) {
    return FolderContentLoaded(
      currentFolder: currentFolder ?? this.currentFolder,
      subfolders: subfolders ?? this.subfolders,
      files: files ?? this.files,
      hasMoreFiles: hasMoreFiles ?? this.hasMoreFiles,
      currentFilter: currentFilter ?? this.currentFilter,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
    );
  }
}


class FolderContentError extends FolderContentState {

  final Failure failure;
  const FolderContentError(this.failure);

  @override
  List<Object?> get props => [failure];
}


class FolderContentLoadingMore extends FolderContentState {

  final Folder currentFolder;
  final List<Folder> subfolders;
  final List<GalleryFile> files;
  final FileFilter currentFilter;

  const FolderContentLoadingMore({
    required this.currentFolder,
    required this.subfolders,
    required this.files,
    required this.currentFilter
  });

  @override
  List<Object?> get props => [currentFolder, subfolders, files, currentFilter];
}