import 'package:equatable/equatable.dart';

import '../../../../../core/errors/base/failures.dart';


abstract class FileManagementState extends Equatable {
  const FileManagementState();

  @override
  List<Object?> get props => [];
}


class FileManagementStarting extends FileManagementState {
  const FileManagementStarting();
}


class FileManagementLoading extends FileManagementState {
  const FileManagementLoading();
}


class FileManagementSuccess extends FileManagementState {

  final String message;
  final int processedCount;

  const FileManagementSuccess({required this.message, required this.processedCount});

  @override
  List<Object?> get props => [message, processedCount];
}


class FileManagementPartialSuccess extends FileManagementState {

  final int successCount;
  final int failedCount;
  final List<String> failedFiles;

  const FileManagementPartialSuccess({
    required this.successCount,
    required this.failedCount,
    required this.failedFiles
  });

  @override
  List<Object?> get props => [successCount, failedCount, failedFiles];
}


class FileManagementError extends FileManagementState {

  final Failure failure;

  const FileManagementError({required this.failure});

  @override
  List<Object?> get props => [failure];
}