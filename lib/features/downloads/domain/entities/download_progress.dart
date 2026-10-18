import 'package:equatable/equatable.dart';

/// Progress of the files queued since the last download started.
class DownloadProgress extends Equatable {
  final int total;
  final int saved;
  final int failed;
  final int bytesTotal;
  final int bytesSaved;

  /// Album of the next file to save; null for the main album of the gallery.
  final String? currentAlbum;

  const DownloadProgress({
    required this.total,
    required this.saved,
    required this.failed,
    required this.bytesTotal,
    required this.bytesSaved,
    this.currentAlbum,
  });

  static const DownloadProgress empty =
      DownloadProgress(total: 0, saved: 0, failed: 0, bytesTotal: 0, bytesSaved: 0);

  int get remaining => total - saved - failed;

  bool get isRunning => remaining > 0;

  bool get isEmpty => total == 0;

  @override
  List<Object?> get props => [total, saved, failed, bytesTotal, bytesSaved, currentAlbum];
}
