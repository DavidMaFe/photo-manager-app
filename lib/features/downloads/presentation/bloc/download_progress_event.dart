import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/download_plan.dart';

abstract class DownloadProgressEvent extends Equatable {
  const DownloadProgressEvent();

  @override
  List<Object?> get props => [];
}

/// Starts following the queue (when the app starts: a download may be running in the background).
class DownloadProgressWatchRequested extends DownloadProgressEvent {
  const DownloadProgressWatchRequested();
}

/// Queues the files of [plan] into the album [album] of the gallery (null: the main one) and follows them.
class DownloadRequested extends DownloadProgressEvent {
  final DownloadPlan plan;
  final String? album;

  const DownloadRequested(this.plan, {this.album});

  @override
  List<Object?> get props => [plan, album];
}

class DownloadCancelRequested extends DownloadProgressEvent {
  const DownloadCancelRequested();
}

/// The progress card was closed after the download finished.
class DownloadProgressDismissed extends DownloadProgressEvent {
  const DownloadProgressDismissed();
}

/// Internal: time to read the queue again.
class DownloadProgressPolled extends DownloadProgressEvent {
  const DownloadProgressPolled();
}
