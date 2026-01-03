import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


abstract class FolderContentEvent extends Equatable {
  const FolderContentEvent();

  @override
  List<Object?> get props => [];
}


class LoadFolderContent extends FolderContentEvent {

  final String folderId;
  const LoadFolderContent({required this.folderId});

  @override
  List<Object?> get props => [];
}


class RefreshFolderContent extends FolderContentEvent {
  const RefreshFolderContent();
}


class LoadMoreFiles extends FolderContentEvent {
  const LoadMoreFiles();
}


class EnterSelectionMode extends FolderContentEvent {
  const EnterSelectionMode();
}


class ExitSelectionMode extends FolderContentEvent {
  const ExitSelectionMode();
}


class ToggleFileSelection extends FolderContentEvent {

  final String fileId;
  const ToggleFileSelection(this.fileId);

  @override
  List<Object?> get props => [fileId];
}


class FilterFilesInFolder extends FolderContentEvent {

  final FileFilter filter;

  const FilterFilesInFolder({required this.filter});

  @override
  List<Object?> get props => [filter];
}