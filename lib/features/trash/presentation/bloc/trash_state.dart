import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';

abstract class TrashState extends Equatable {
  const TrashState();

  @override
  List<Object?> get props => [];
}

// Initial state
class TrashInitial extends TrashState {
  const TrashInitial();
}

// Loading first page
class TrashLoading extends TrashState {
  const TrashLoading();
}

// Loaded with files
class TrashLoaded extends TrashState {
  final List<TrashFile> files;
  final int currentPage;
  final bool hasNext;
  final bool isSelectionMode;
  final Set<String> selectedFileIds;

  const TrashLoaded({
    required this.files,
    required this.currentPage,
    required this.hasNext,
    this.isSelectionMode = false,
    this.selectedFileIds = const {},
  });

  /// Check if a file is selected
  bool isFileSelected(String fileId) => selectedFileIds.contains(fileId);

  /// Get count of selected files
  int get selectedCount => selectedFileIds.length;

  /// Check if all files are selected
  bool get areAllFilesSelected =>
      files.isNotEmpty && selectedFileIds.length == files.length;

  @override
  List<Object?> get props => [
        files,
        currentPage,
        hasNext,
        isSelectionMode,
        selectedFileIds,
      ];

  TrashLoaded copyWith({
    List<TrashFile>? files,
    int? currentPage,
    bool? hasNext,
    bool? isSelectionMode,
    Set<String>? selectedFileIds,
  }) {
    return TrashLoaded(
      files: files ?? this.files,
      currentPage: currentPage ?? this.currentPage,
      hasNext: hasNext ?? this.hasNext,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedFileIds: selectedFileIds ?? this.selectedFileIds,
    );
  }
}

// Loading more files (pagination)
class TrashLoadingMore extends TrashLoaded {
  const TrashLoadingMore({
    required super.files,
    required super.currentPage,
    required super.hasNext,
    super.isSelectionMode,
    super.selectedFileIds,
  });
}

// Error state
class TrashError extends TrashState {
  final Failure failure;

  const TrashError(this.failure);

  @override
  List<Object?> get props => [failure];
}

// Action states (restore/delete operations)
class TrashRestoring extends TrashLoaded {
  const TrashRestoring({
    required super.files,
    required super.currentPage,
    required super.hasNext,
    super.isSelectionMode,
    super.selectedFileIds,
  });
}

class TrashRestoreSuccess extends TrashState {
  final int restoredCount;

  const TrashRestoreSuccess(this.restoredCount);

  @override
  List<Object?> get props => [restoredCount];
}

class TrashRestoreError extends TrashLoaded {
  final Failure failure;

  const TrashRestoreError({
    required this.failure,
    required super.files,
    required super.currentPage,
    required super.hasNext,
    super.isSelectionMode,
    super.selectedFileIds,
  });

  @override
  List<Object?> get props => [
        failure,
        files,
        currentPage,
        hasNext,
        isSelectionMode,
        selectedFileIds,
      ];
}

class TrashDeleting extends TrashLoaded {
  const TrashDeleting({
    required super.files,
    required super.currentPage,
    required super.hasNext,
    super.isSelectionMode,
    super.selectedFileIds,
  });
}

class TrashDeleteSuccess extends TrashState {
  final int deletedCount;

  const TrashDeleteSuccess(this.deletedCount);

  @override
  List<Object?> get props => [deletedCount];
}

class TrashDeleteError extends TrashLoaded {
  final Failure failure;

  const TrashDeleteError({
    required this.failure,
    required super.files,
    required super.currentPage,
    required super.hasNext,
    super.isSelectionMode,
    super.selectedFileIds,
  });

  @override
  List<Object?> get props => [
        failure,
        files,
        currentPage,
        hasNext,
        isSelectionMode,
        selectedFileIds,
      ];
}
