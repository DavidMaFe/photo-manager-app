import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


abstract class GalleryState extends Equatable {
  const GalleryState();

  @override
  List<Object?> get props => [];
}


class GalleryStarting extends GalleryState {
  const GalleryStarting();

  @override
  String toString() => 'GalleryStarting';
}


class GalleryLoading extends GalleryState {
  final FileFilter filter;

  const GalleryLoading({this.filter = FileFilter.all});

  @override
  List<Object?> get props => [filter];

  @override
  String toString() => 'GalleryLoading (filter: $filter)';
}


class GalleryLoaded extends GalleryState {

  final List<GalleryFile> files;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final bool hasNext;
  final int currentPage;
  final FileFilter filter;

  const GalleryLoaded({
    required this.files,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.hasNext,
    required this.currentPage,
    required this.filter
  });

  int get pendingCount => files.where((f) => f.isPending).length;
  bool get hasPendingFiles => pendingCount > 0;
  bool get isEmpty => files.isEmpty;

  GalleryLoaded copyWith({
    List<GalleryFile>? files,
    bool? isSelectionMode,
    Set<String>? selectedFileIds,
    bool? hasNext,
    int? currentPage,
    FileFilter? filter
  }) {
    return GalleryLoaded(
      files: files ?? this.files,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter
    );
  }

  @override
  List<Object?> get props => [files, isSelectionMode, selectedFileIds, hasNext,
    currentPage, filter];
}


class GalleryLoadingMore extends GalleryState {

  final List<GalleryFile> files;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;
  final int currentPage;
  final FileFilter filter;

  const GalleryLoadingMore({
    required this.files,
    required this.isSelectionMode,
    required this.selectedFileIds,
    required this.currentPage,
    required this.filter
  });

  int get pendingCount => files.where((f) => f.isPending).length;
  bool get hasPendingFiles => pendingCount > 0;

  GalleryLoadingMore copyWith({
    List<GalleryFile>? files,
    bool? isSelectionMode,
    Set<String>? selectedFileIds,
    int? currentPage,
    FileFilter? filter
  }) {
    return GalleryLoadingMore(
        files: files ?? this.files,
        isSelectionMode: isSelectionMode ?? this.isSelectionMode,
        selectedFileIds: selectedFileIds ?? this.selectedFileIds,
        currentPage: currentPage ?? this.currentPage,
        filter: filter ?? this.filter
    );
  }

  @override
  List<Object?> get props => [files, isSelectionMode, selectedFileIds, currentPage, filter];
}


class GalleryError extends GalleryState {

  final Failure failure;
  const GalleryError(this.failure);

  @override
  List<Object?> get props => [failure];
}