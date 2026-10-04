import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';


class Synchronization extends Equatable {

  final String id;
  final DateTime startedAt;
  final SynchronizationStatus status;
  final int totalFiles;
  final int uploadedFiles;
  final int failedFiles;
  final DateTime? completedAt;
  final DateTime? cancelledAt;

  /// Bytes uploaded by the session; 0 while unknown.
  final int totalSizeBytes;

  const Synchronization({
    required this.id,
    required this.startedAt,
    required this.status,
    required this.totalFiles,
    required this.uploadedFiles,
    required this.failedFiles,
    this.completedAt,
    this.cancelledAt,
    this.totalSizeBytes = 0
  });

  bool get isCompleted => status == SynchronizationStatus.completed;
  bool get isInProgress => status == SynchronizationStatus.inProgress;
  bool get hasFailed => status == SynchronizationStatus.failed;

  /// When the backup ended (completed or cancelled), or when it started if unknown.
  DateTime get endedAt => completedAt ?? cancelledAt ?? startedAt;

  @override
  List<Object?> get props => [
    id, startedAt, status, totalFiles, uploadedFiles, failedFiles, completedAt, cancelledAt, totalSizeBytes
  ];
}
