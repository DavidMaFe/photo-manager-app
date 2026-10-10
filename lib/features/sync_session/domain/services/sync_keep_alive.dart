/// Keeps the app running while a sync uploads files, also with the screen off. Without it, the OS freezes the app
/// when the phone sleeps (One UI does it within minutes) and the session is left half done.
abstract class SyncKeepAlive {
  /// Called when the sync starts. Safe to call again.
  Future<void> start();

  /// Progress of the upload, shown to the user while the sync runs.
  Future<void> update({required int current, required int total});

  /// Called when the sync ends, however it ends. Safe to call without [start].
  Future<void> stop();
}
