import 'package:photo_manager_app/features/sync_session/domain/entities/duplicate_files_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';


class CheckDuplicatedFilesUseCase {

  final SyncSessionRepository _syncSessionRepository;
  CheckDuplicatedFilesUseCase(this._syncSessionRepository);

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
        throw Exception("Invalid hash detected: ${hash.substring(0, 8)}...");
      }
    }

    final uniqueHashes = fileHashes.toSet().toList();
    if (uniqueHashes.length < fileHashes.length) {
      final duplicatesInList = fileHashes.length - uniqueHashes.length;
      print("Detected $duplicatesInList duplicated hashes in the local list");
    }

    return await _syncSessionRepository.checkDuplicates(
        sessionId: sessionId, fileHashes: fileHashes
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