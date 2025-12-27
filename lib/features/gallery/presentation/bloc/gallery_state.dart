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
  final bool hasNext;
  final int currentPage;
  final FileFilter filter;

  const GalleryLoaded({
    required this.files,
    required this.hasNext,
    required this.currentPage,
    required this.filter
  });

  int get pendingCount => files.where((f) => f.isPending).length;
  bool get hasPendingFiles => pendingCount > 0;
  bool get isEmpty => files.isEmpty;

  GalleryLoaded copyWith({
    List<GalleryFile>? files,
    bool? hasNext,
    int? currentPage,
    FileFilter? filter
  }) {
    return GalleryLoaded(
      files: files ?? this.files,
      hasNext: hasNext ?? this.hasNext,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter
    );
  }

  @override
  List<Object?> get props => [files, hasNext, currentPage, filter];
}


class GalleryLoadingMore extends GalleryState {

  final List<GalleryFile> files;
  final int currentPage;
  final FileFilter filter;

  const GalleryLoadingMore({
    required this.files,
    required this.currentPage,
    required this.filter
  });

  int get pendingCount => files.where((f) => f.isPending).length;
  bool get hasPendingFiles => pendingCount > 0;

  @override
  List<Object?> get props => [files, currentPage, filter];
}


class GalleryError extends GalleryState {

  final Failure failure;
  const GalleryError(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'GalleryError (code: ${failure.code})';
}