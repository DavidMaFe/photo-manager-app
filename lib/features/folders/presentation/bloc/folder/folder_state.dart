import 'package:equatable/equatable.dart';

import '../../../../../core/errors/base/failures.dart';
import '../../../domain/entities/folder.dart';


abstract class FolderState extends Equatable {
  const FolderState();

  @override
  List<Object?> get props => [];
}


class FolderStarting extends FolderState {
  const FolderStarting();
}


class FolderLoading extends FolderState {
  const FolderLoading();
}


class FolderLoaded extends FolderState {
  final List<Folder> folders;
  final String? currentParentId;

  const FolderLoaded({required this.folders, this.currentParentId});

  @override
  List<Object?> get props => [folders, currentParentId];
}


class FolderError extends FolderState {

  final Failure failure;
  const FolderError(this.failure);

  @override
  List<Object?> get props => [failure];
}


class FolderOperationLoading extends FolderState {

  final String operation;
  const FolderOperationLoading({required this.operation});

  @override
  List<Object?> get props => [operation];
}


class FolderOperationSuccess extends FolderState {

  final String operation;
  final String message;

  const FolderOperationSuccess({required this.operation, required this.message});

  @override
  List<Object?> get props => [operation, message];
}


class FolderOperationError extends FolderState {

  final String operation;
  final Failure failure;

  const FolderOperationError({required this.operation, required this.failure});

  @override
  List<Object?> get props => [operation, failure];
}