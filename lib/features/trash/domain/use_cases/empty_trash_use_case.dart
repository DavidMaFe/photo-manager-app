import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';

class EmptyTrashUseCase {
  final TrashRepository _repository;

  EmptyTrashUseCase(this._repository);

  Future<void> call() async {
    return await _repository.emptyTrash();
  }
}
