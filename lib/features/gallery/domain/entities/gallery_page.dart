
import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';

class GalleryPage extends Equatable {

  final List<GalleryFile> files;
  final int currentPage;
  final int pageSize;
  final bool hasNext;
  final int totalFilesCount;
  final int totalPendingCount;

  const GalleryPage({
    required this.files,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
    required this.totalFilesCount,
    required this.totalPendingCount
  });

  factory GalleryPage.empty() {
    return const GalleryPage(
      files: [],
      currentPage: 0,
      pageSize: 0,
      hasNext: false,
      totalFilesCount: 0,
      totalPendingCount: 0
    );
  }

  bool get isEmpty => files.isEmpty;
  bool get isNotEmpty => files.isNotEmpty;
  bool get isFirstPage => currentPage == 0;
  bool get hasPrevious => currentPage > 0;
  int? get nextPage => hasNext ? currentPage + 1 : null;

  GalleryPage copyWith({
    List<GalleryFile>? files,
    int? currentPage,
    int? pageSize,
    bool? hasNext,
    int? totalFilesCount,
    int? totalPendingCount
  }) {
    return GalleryPage(
      files:  files ?? this.files,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNext: hasNext ?? this.hasNext,
      totalFilesCount: totalFilesCount ?? this.totalFilesCount,
      totalPendingCount: totalPendingCount ?? this.totalPendingCount
    );
  }

  @override
  List<Object?> get props => [files, currentPage, pageSize, hasNext, totalFilesCount, totalPendingCount];
}