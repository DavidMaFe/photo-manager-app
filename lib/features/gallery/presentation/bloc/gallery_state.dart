import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/file_date_group.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}


class GalleryStarting extends GalleryState {
  const GalleryStarting();
}


class GalleryLoading extends GalleryState {
  final FileFilter filter;

  const GalleryLoading({this.filter = FileFilter.all});

  @override
  List<Object?> get props => [filter];
}


class GalleryLoaded extends GalleryState {

  final List<GalleryFile> files;
  final List<FileDateGroup> groupedFiles;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final bool hasNext;
  final int currentPage;
  final int totalFilesCount;
  final int totalPendingCount;
  final FileFilter filter;
  final bool selectionLimitReached;
  final bool isRefreshing;

  /// One-shot: the pending files are selected and the manage sheet should open.
  final bool reviewRequested;

  const GalleryLoaded({
    required this.files,
    required this.groupedFiles,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.hasNext,
    required this.currentPage,
    required this.totalFilesCount,
    required this.totalPendingCount,
    required this.filter,
    this.selectionLimitReached = false,
    this.isRefreshing = false,
    this.reviewRequested = false,
  });

  int get pendingCount => totalPendingCount;
  bool get hasPendingFiles => pendingCount > 0;
  bool get isEmpty => files.isEmpty;
  bool get areAllFilesSelected =>
      files.isNotEmpty &&
      (selectedFileIds.length == files.length || selectedFileIds.length >= 100);

  GalleryLoaded copyWith({
    List<GalleryFile>? files,
    List<FileDateGroup>? groupedFiles,
    bool? isSelectionMode,
    Set<String>? selectedFileIds,
    bool? hasNext,
    int? currentPage,
    int? totalFilesCount,
    int? totalPendingCount,
    FileFilter? filter,
    bool selectionLimitReached = false,
    bool isRefreshing = false,
  }) {
    // One-shot flags (limit reached, review requested) reset on every copy.
    return GalleryLoaded(
      files: files ?? this.files,
      groupedFiles: groupedFiles ?? this.groupedFiles,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      totalFilesCount: totalFilesCount ?? this.totalFilesCount,
      totalPendingCount: totalPendingCount ?? this.totalPendingCount,
      filter: filter ?? this.filter,
      selectionLimitReached: selectionLimitReached,
      isRefreshing: isRefreshing,
    );
  }

  @override
  List<Object?> get props => [files, groupedFiles, isSelectionMode, selectedFileIds, hasNext,
    currentPage, totalFilesCount, totalPendingCount, filter, selectionLimitReached, isRefreshing,
    reviewRequested];
}


class GalleryLoadingMore extends GalleryState {

  final List<GalleryFile> files;
  final List<FileDateGroup> groupedFiles;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final int currentPage;
  final int totalFilesCount;
  final int totalPendingCount;
  final FileFilter filter;

  const GalleryLoadingMore({
    required this.files,
    required this.groupedFiles,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.currentPage,
    required this.totalFilesCount,
    required this.totalPendingCount,
    required this.filter
  });

  int get pendingCount => totalPendingCount;
  bool get hasPendingFiles => pendingCount > 0;

  GalleryLoadingMore copyWith({
    List<GalleryFile>? files,
    List<FileDateGroup>? groupedFiles,
    bool? isSelectionMode,
    Set<String>? selectedFileIds,
    int? currentPage,
    int? totalFilesCount,
    int? totalPendingCount,
    FileFilter? filter
  }) {
    return GalleryLoadingMore(
        files: files ?? this.files,
        groupedFiles: groupedFiles ?? this.groupedFiles,
        isSelectionMode: isSelectionMode ?? this.isSelectionMode,
        selectedFileIds: selectedFileIds ?? this.selectedFileIds,
        currentPage: currentPage ?? this.currentPage,
        totalFilesCount: totalFilesCount ?? this.totalFilesCount,
        totalPendingCount: totalPendingCount ?? this.totalPendingCount,
        filter: filter ?? this.filter
    );
  }

  @override
  List<Object?> get props => [files, groupedFiles, isSelectionMode, selectedFileIds, currentPage, totalFilesCount, totalPendingCount, filter];
}


class GalleryError extends GalleryState {

  final Failure failure;
  const GalleryError(this.failure);

  @override
  List<Object?> get props => [failure];
}