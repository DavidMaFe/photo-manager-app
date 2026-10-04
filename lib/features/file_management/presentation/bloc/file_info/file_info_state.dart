import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';


abstract class FileInfoState extends Equatable {
  const FileInfoState();

  @override
  List<Object?> get props => [];
}


class FileInfoLoading extends FileInfoState {
  const FileInfoLoading();
}


class FileInfoLoaded extends FileInfoState {

  final FileInfo info;
  const FileInfoLoaded(this.info);

  @override
  List<Object?> get props => [info];
}


class FileInfoError extends FileInfoState {

  final Failure failure;
  const FileInfoError(this.failure);

  @override
  List<Object?> get props => [failure];
}
