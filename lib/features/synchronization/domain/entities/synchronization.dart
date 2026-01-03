import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';


class Synchronization extends Equatable {

  final String id;
  final DateTime startedAt;
  final SynchronizationStatus status;
  final int totalFiles;
  final int uploadedFiles;
  final int failedFiles;

  const Synchronization({
    required this.id,
    required this.startedAt,
    required this.status,
    required this.totalFiles,
    required this.uploadedFiles,
    required this.failedFiles
  });

  bool get isCompleted => status == SynchronizationStatus.completed;
  bool get isInProgress => status == SynchronizationStatus.inProgress;
  bool get hasFailed => status == SynchronizationStatus.failed;

  @override
  List<Object?> get props => [id, startedAt, status, totalFiles, uploadedFiles, failedFiles];
}