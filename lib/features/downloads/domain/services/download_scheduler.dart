/// Runs the download queue in the background, also when the app is closed.
abstract class DownloadScheduler {
  Future<void> schedule();

  Future<void> cancel();
}
