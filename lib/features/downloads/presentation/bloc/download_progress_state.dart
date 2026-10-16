import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';

/// What happened with the last request, for a message.
class DownloadOutcome extends Equatable {
  /// Files queued; 0 when every requested file was already on the device.
  final int started;
  final int requested;

  const DownloadOutcome({required this.started, required this.requested});

  @override
  List<Object?> get props => [started, requested];
}

class DownloadProgressState extends Equatable {
  final DownloadProgress progress;

  /// Estimated time left, once enough has been saved to measure the speed.
  final Duration? remaining;

  /// Why the last download could not start (e.g. not enough space); cleared by the next request.
  final Failure? failure;

  /// The user closed the card of a finished download.
  final bool dismissed;

  /// Result of the last request; [outcomeSerial] changes with each one so listeners show every message.
  final DownloadOutcome? outcome;
  final int outcomeSerial;

  const DownloadProgressState({
    this.progress = DownloadProgress.empty,
    this.remaining,
    this.failure,
    this.dismissed = false,
    this.outcome,
    this.outcomeSerial = 0,
  });

  bool get isRunning => progress.isRunning;

  /// There is something to show: a download running or one that finished and was not dismissed.
  bool get isVisible => !progress.isEmpty && (progress.isRunning || !dismissed);

  DownloadProgressState copyWith({
    DownloadProgress? progress,
    Duration? Function()? remaining,
    Failure? Function()? failure,
    bool? dismissed,
    DownloadOutcome? outcome,
  }) =>
      DownloadProgressState(
        progress: progress ?? this.progress,
        remaining: remaining != null ? remaining() : this.remaining,
        failure: failure != null ? failure() : this.failure,
        dismissed: dismissed ?? this.dismissed,
        outcome: outcome ?? this.outcome,
        outcomeSerial: outcome != null ? outcomeSerial + 1 : outcomeSerial,
      );

  @override
  List<Object?> get props => [progress, remaining, failure, dismissed, outcome, outcomeSerial];
}
