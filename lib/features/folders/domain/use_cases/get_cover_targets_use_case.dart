import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';

import '../entities/cover_target.dart';
import '../repositories/covers_repository.dart';


/// Albums 1–3 photos can be covers of (their common ancestors, root first).
class GetCoverTargetsUseCase {

  final CoversRepository _repository;
  GetCoverTargetsUseCase(this._repository);

  Future<List<CoverTarget>> call(List<String> fileIds) async {
    final ids = fileIds.toSet().toList();
    if (ids.isEmpty) {
      throw const ValidationFailure(code: FailureCodes.folderCoverFileNotValid);
    }
    if (ids.length > kMaxAlbumCovers) {
      throw const ValidationFailure(code: FailureCodes.folderCoversLimitExceeded);
    }
    return await _repository.getCoverTargets(ids);
  }
}
