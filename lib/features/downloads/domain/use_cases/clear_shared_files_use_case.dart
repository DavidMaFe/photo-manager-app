import 'package:photo_manager_app/features/downloads/domain/repositories/share_repository.dart';

/// Removes the decrypted temporary files of the share sheet: when the app comes back to the foreground (the other
/// app already copied them, ROADMAP-downloads-and-account-deletion.md, Phase 0), when it starts and at logout.
class ClearSharedFilesUseCase {
  final ShareRepository _share;

  ClearSharedFilesUseCase(this._share);

  Future<void> call() async {
    try {
      await _share.clearTemporary();
    } catch (_) {
      // Tried again the next time the app comes back
    }
  }
}
