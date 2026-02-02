import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';

class TrashPage extends Equatable {
  final List<TrashFile> files;
  final int currentPage;
  final int pageSize;
  final bool hasNext;

  const TrashPage({
    required this.files,
    required this.currentPage,
    required this.pageSize,
    required this.hasNext,
  });

  factory TrashPage.empty() {
    return const TrashPage(
      files: [],
      currentPage: 0,
      pageSize: 0,
      hasNext: false,
    );
  }

  /// Check if there are no files in trash
  bool get isEmpty => files.isEmpty;

  /// Check if there are files in trash
  bool get isNotEmpty => files.isNotEmpty;

  /// Check if this is the first page
  bool get isFirstPage => currentPage == 0;

  /// Check if there's a previous page
  bool get hasPrevious => currentPage > 0;

  /// Get next page number if available
  int? get nextPage => hasNext ? currentPage + 1 : null;

  @override
  List<Object?> get props => [
        files,
        currentPage,
        pageSize,
        hasNext,
      ];

  TrashPage copyWith({
    List<TrashFile>? files,
    int? currentPage,
    int? pageSize,
    bool? hasNext,
  }) {
    return TrashPage(
      files: files ?? this.files,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      hasNext: hasNext ?? this.hasNext,
    );
  }
}
