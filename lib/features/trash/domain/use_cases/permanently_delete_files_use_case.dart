import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';

class PermanentlyDeleteFilesUseCase {
  final TrashRepository _repository;

  PermanentlyDeleteFilesUseCase(this._repository);

  Future<void> call(List<String> fileIds) async {
    if (fileIds.isEmpty) {
      throw ArgumentError('File IDs list cannot be empty');
    }

    // Validate all IDs are non-empty
    if (fileIds.any((id) => id.trim().isEmpty)) {
      throw ArgumentError('File IDs cannot be empty strings');
    }

    return await _repository.permanentlyDeleteFiles(fileIds);
  }
}
