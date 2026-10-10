import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/services/dedup_hasher.dart';


/// Asks the server which files are already uploaded. The server only sees keyed hashes (docs/e2ee-spec.md, 7.2); the
/// result comes back as the content hashes of this device.
class CheckDuplicatedFilesUseCase {

  final SyncSessionRepository _syncSessionRepository;
  final DedupHasher _dedupHasher;

  CheckDuplicatedFilesUseCase(this._syncSessionRepository, this._dedupHasher);

  Future<DuplicateFilesResult> call({
    required String sessionId,
    required List<String> fileHashes
  }) async {

    if (sessionId.trim().isEmpty) {
      throw Exception("Invalid Sync Session ID");
    }

    if (fileHashes.isEmpty){
      throw Exception("It must be at least one file to check");
    }

    for (final hash in fileHashes) {
      if (!_isValidHash(hash)) {
        throw Exception("Invalid hash detected");
      }
    }

    final dedupByContent = await _dedupHasher.hashes(fileHashes);
    final contentByDedup = {for (final entry in dedupByContent.entries) entry.value: entry.key};

    final result = await _syncSessionRepository.checkDuplicates(
        sessionId: sessionId, fileHashes: dedupByContent.values.toSet().toList()
    );

    return DuplicateFilesResult(
      filesToUpload: [
        for (final dedup in result.filesToUpload)
          if (contentByDedup[dedup] case final content?) content,
      ],
      duplicatesCount: result.duplicatesCount,
      totalFiles: result.totalFiles,
    );
  }

  bool _isValidHash(String hash) {
    if (hash.length != 64) {
      return false;
    }

    final hexRegex = RegExp(r'^[0-9a-fA-F]+$');
    return hexRegex.hasMatch(hash);
  }
}
