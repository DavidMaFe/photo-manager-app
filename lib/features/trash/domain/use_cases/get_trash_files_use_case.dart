import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';

class GetTrashFilesUseCase {
  final TrashRepository _repository;

  GetTrashFilesUseCase(this._repository);

  Future<TrashPage> call({
    required int page,
    required int pageSize,
  }) async {
    if (page < 0) {
      throw ArgumentError('Page number must be non-negative');
    }

    if (pageSize <= 0 || pageSize > 100) {
      throw ArgumentError('Page size must be between 1 and 100');
    }

    return await _repository.getTrashFiles(
      page: page,
      pageSize: pageSize,
    );
  }
}
