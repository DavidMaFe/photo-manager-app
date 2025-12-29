import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';


abstract class FileManagementEvent extends Equatable {
  const FileManagementEvent();

  @override
  List<Object?> get props => [];
}


class ManagedFilesRequested extends FileManagementEvent {

  final List<String> fileIds;
  final ManageAction action;

  const ManagedFilesRequested({required this.fileIds, required this.action});

  @override
  List<Object?> get props => [fileIds, action];
}