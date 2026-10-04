import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';


/// IDs and total size of every pending file, optionally of one type or album.
class GetPendingFileIdsUseCase {

  final GalleryRepository _repository;
  GetPendingFileIdsUseCase(this._repository);

  Future<PendingFiles> call({FileType? type, String? folderId}) async {
    return await _repository.getPendingFileIds(type: type, folderId: folderId);
  }
}
