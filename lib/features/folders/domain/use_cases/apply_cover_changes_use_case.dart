import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';

import '../entities/cover_change.dart';
import '../entities/cover_target.dart';
import '../entities/folder_covers.dart';
import '../enums/cover_change_action.dart';
import '../repositories/covers_repository.dart';


/// Applies the cover changes chosen for 1–3 photos.
///
/// Every change is checked against the current covers of [targets] before
/// anything is sent, so a full album without a replacement never reaches the
/// server half-applied. Each photo is then sent in one all-or-nothing request.
class ApplyCoverChangesUseCase {

  final CoversRepository _repository;
  ApplyCoverChangesUseCase(this._repository);

  /// Returns the final covers of every album changed (the last state of each).
  Future<List<FolderCovers>> call({
    required List<CoverTarget> targets,
    required Map<String, List<CoverChange>> changesByFile,
  }) async {
    final changes = {
      for (final entry in changesByFile.entries)
        if (entry.value.isNotEmpty) entry.key: entry.value,
    };
    _validate(targets, changes);

    final foldersById = <String, FolderCovers>{};
    for (final entry in changes.entries) {
      final result = await _repository.applyCoverChanges(entry.key, entry.value);
      for (final folder in result) {
        foldersById[folder.folderId] = folder;
      }
    }
    return foldersById.values.toList();
  }

  void _validate(List<CoverTarget> targets, Map<String, List<CoverChange>> changesByFile) {
    if (changesByFile.isEmpty) {
      throw const ValidationFailure(code: FailureCodes.validationError);
    }
    if (changesByFile.length > kMaxAlbumCovers) {
      throw const ValidationFailure(code: FailureCodes.folderCoversLimitExceeded);
    }

    final targetsById = {for (final target in targets) target.folderId: target};
    // Covers of each album as the changes are applied, to check them together.
    final coversByFolder = {
      for (final target in targets) target.folderId: target.covers.map((cover) => cover.fileId).toList(),
    };

    for (final MapEntry(key: fileId, value: changes) in changesByFile.entries) {
      final changedFolders = <String>{};
      for (final change in changes) {
        final target = targetsById[change.folderId];
        if (target == null || !changedFolders.add(change.folderId)) {
          throw const ValidationFailure(code: FailureCodes.folderCoverFileNotValid);
        }
        final covers = coversByFolder[change.folderId]!;

        switch (change.action) {
          case CoverChangeAction.add:
            if (covers.contains(fileId)) {
              throw const ValidationFailure(code: FailureCodes.folderCoverDuplicated);
            }
            if (covers.length >= kMaxAlbumCovers) {
              throw const ValidationFailure(code: FailureCodes.folderCoversLimitExceeded);
            }
            covers.add(fileId);
          case CoverChangeAction.remove:
            if (!covers.remove(fileId)) {
              throw const ValidationFailure(code: FailureCodes.folderCoverFileNotValid);
            }
          case CoverChangeAction.replace:
            final index = covers.indexOf(change.replaceFileId ?? '');
            if (index < 0 || covers.contains(fileId)) {
              throw const ValidationFailure(code: FailureCodes.folderCoverReplaceNotValid);
            }
            covers[index] = fileId;
        }
      }
    }
  }
}
