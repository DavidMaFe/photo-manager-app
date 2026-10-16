import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_progress.dart';

class DownloadProgressState extends Equatable {
  final DownloadProgress progress;

  /// Estimated time left, once enough has been saved to measure the speed.
  final Duration? remaining;

  /// Why the last download could not start (e.g. not enough space); cleared by the next request.
  final Failure? failure;

  /// The user closed the card of a finished download.
  final bool dismissed;

  const DownloadProgressState({
    this.progress = DownloadProgress.empty,
    this.remaining,
    this.failure,
    this.dismissed = false,
  });

  bool get isRunning => progress.isRunning;

  /// There is something to show: a download running or one that finished and was not dismissed.
  bool get isVisible => !progress.isEmpty && (progress.isRunning || !dismissed);

  DownloadProgressState copyWith({
    DownloadProgress? progress,
    Duration? Function()? remaining,
    Failure? Function()? failure,
    bool? dismissed,
  }) =>
      DownloadProgressState(
        progress: progress ?? this.progress,
        remaining: remaining != null ? remaining() : this.remaining,
        failure: failure != null ? failure() : this.failure,
        dismissed: dismissed ?? this.dismissed,
      );

  @override
  List<Object?> get props => [progress, remaining, failure, dismissed];
}
