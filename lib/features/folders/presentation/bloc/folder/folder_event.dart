import 'package:equatable/equatable.dart';


abstract class FolderEvent extends Equatable {
  const FolderEvent();

  @override
  List<Object?> get props => [];
}


class LoadFolders extends FolderEvent {

  final String? parentFolderId;
  const LoadFolders ({this.parentFolderId});

  @override
  List<Object?> get props => [parentFolderId];
}


class RefreshFolders extends FolderEvent {
  const RefreshFolders();
}


class CreateFolderRequested extends FolderEvent {

  final String name;
  final String? parentFolderId;

  const CreateFolderRequested({required this.name, this.parentFolderId});

  @override
  List<Object?> get props => [name, parentFolderId];
}


class RenameFolderRequested extends FolderEvent {

  final String folderId;
  final String newName;

  const RenameFolderRequested({required this.folderId, required this.newName});

  @override
  List<Object?> get props => [folderId, newName];
}


class DeleteFolderRequested extends FolderEvent {

  final String folderId;
  const DeleteFolderRequested({required this.folderId});

  @override
  List<Object?> get props => [folderId];
}