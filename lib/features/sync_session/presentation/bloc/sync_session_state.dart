import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';

import '../../../../core/errors/base/failures.dart';


abstract class SyncSessionState extends Equatable {
  const SyncSessionState();

  @override
  List<Object?> get props => [];
}


class SyncSessionInitial extends SyncSessionState {
  const SyncSessionInitial();

  @override
  String toString() => 'SyncSessionInitial';
}


class SyncSessionStarting extends SyncSessionState {
  const SyncSessionStarting();

  @override
  String toString() => 'SyncSessionStarting';
}


class SyncSessionFetchingFiles extends SyncSessionState {
  const SyncSessionFetchingFiles();

  @override
  String toString() => 'SyncSessionFetchingFiles';
}


class SyncSessionUploading extends SyncSessionState {

  final int uploadCount;
  final int totalCount;
  final String? currentFileName;

  const SyncSessionUploading({
    required this.uploadCount,
    required this.totalCount,
    this.currentFileName
  });

  double get progress {
    if (totalCount == 0) return 0.0;
    return uploadCount / totalCount;
  }

  int get progressPercentage => (progress * 100).round();
  bool get isComplete => uploadCount >= totalCount;

  @override
  List<Object?> get props => [uploadCount, totalCount, currentFileName];

  @override
  String toString() => 'SyncSessionUploading (uploaded: $uploadCount/$totalCount, $progressPercentage%)';
}


class SyncSessionCompleting extends SyncSessionState {
  const SyncSessionCompleting();

  @override
  String toString() => 'SyncSessionCompleting';
}


class SyncSessionSuccess extends SyncSessionState {

  final SyncResult result;
  const SyncSessionSuccess(this.result);

  @override
  List<Object?> get props => [result];

  @override
  String toString() => 'SyncSessionSuccess (uploaded: ${result.uploadedFiles}/${result.totalFiles})';
}


class SyncSessionCancelling extends SyncSessionState {

  final int? uploadedCount;
  const SyncSessionCancelling(this.uploadedCount);

  @override
  List<Object?> get props => [uploadedCount];

  @override
  String toString() => 'SyncSessionCancelling (uploaded: $uploadedCount)';
}


class SyncSessionError extends SyncSessionState {

  final Failure failure;
  const SyncSessionError(this.failure);

  @override
  List<Object?> get props => [failure];

  @override
  String toString() => 'SyncSessionError (code: ${failure.code})';

}