import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';


abstract class ManageFolderState extends Equatable {
  const ManageFolderState();

  @override
  List<Object?> get props => [];
}


class ManageFolderStarting extends ManageFolderState {
  const ManageFolderStarting();
}


class ManageFoldersLoading extends ManageFolderState {
  const ManageFoldersLoading();
}


class ManageFoldersLoaded extends ManageFolderState {

  final List<ManageFolder> folders;
  const ManageFoldersLoaded({required this.folders});

  @override
  List<Object?> get props => [folders];
}


class ManageFolderError extends ManageFolderState {

  final Failure failure;
  const ManageFolderError({required this.failure});

  @override
  List<Object?> get props => [failure];
}