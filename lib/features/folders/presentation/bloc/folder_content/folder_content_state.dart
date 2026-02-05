import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


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
  final List<FileDateGroup> groupedFiles;
  final bool hasMoreFiles;
  final FileFilter currentFilter;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;

  const FolderContentLoaded({
    required this.currentFolder,
    required this.subfolders,
    required this.files,
    required this.groupedFiles,
    required this.hasMoreFiles,
    this.currentFilter = FileFilter.all,
    this.isSelectionMode = false,
    this.selectedFileIds = const {}
  });

  bool get areAllFilesSelected => files.isNotEmpty && selectedFileIds.length == files.length;

  @override
  List<Object?> get props => [currentFolder, subfolders, files, groupedFiles, hasMoreFiles,
    currentFilter, isSelectionMode, selectedFileIds];

  FolderContentLoaded copyWith({
    Folder? currentFolder,
    List<Folder>? subfolders,
    List<GalleryFile>? files,
    List<FileDateGroup>? groupedFiles,
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
      groupedFiles: groupedFiles ?? this.groupedFiles,
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
  final List<FileDateGroup> groupedFiles;
  final FileFilter currentFilter;

  const FolderContentLoadingMore({
    required this.currentFolder,
    required this.subfolders,
    required this.files,
    required this.groupedFiles,
    required this.currentFilter
  });

  @override
  List<Object?> get props => [currentFolder, subfolders, files, groupedFiles, currentFilter];
}