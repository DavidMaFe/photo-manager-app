import 'package:equatable/equatable.dart';

abstract class TrashEvent extends Equatable {
  const TrashEvent();

  @override
  List<Object?> get props => [];
}

// Load trash files
class LoadTrash extends TrashEvent {
  const LoadTrash();
}

// Load more files (pagination)
class LoadMoreTrash extends TrashEvent {
  const LoadMoreTrash();
}

// Refresh trash (pull-to-refresh)
class RefreshTrash extends TrashEvent {
  const RefreshTrash();
}

// Selection mode events
class EnterSelectionMode extends TrashEvent {
  const EnterSelectionMode();
}

class ExitSelectionMode extends TrashEvent {
  const ExitSelectionMode();
}

class ToggleFileSelection extends TrashEvent {
  final String fileId;

  const ToggleFileSelection(this.fileId);

  @override
  List<Object?> get props => [fileId];
}

class SelectAllFiles extends TrashEvent {
  const SelectAllFiles();
}

class ClearSelection extends TrashEvent {
  const ClearSelection();
}

// Action events
class RestoreSelectedFiles extends TrashEvent {
  const RestoreSelectedFiles();
}

class RestoreFiles extends TrashEvent {
  final List<String> fileIds;

  const RestoreFiles(this.fileIds);

  @override
  List<Object?> get props => [fileIds];
}

class PermanentlyDeleteSelectedFiles extends TrashEvent {
  const PermanentlyDeleteSelectedFiles();
}

class PermanentlyDeleteFiles extends TrashEvent {
  final List<String> fileIds;

  const PermanentlyDeleteFiles(this.fileIds);

  @override
  List<Object?> get props => [fileIds];
}

class EmptyTrashRequested extends TrashEvent {
  const EmptyTrashRequested();
}
