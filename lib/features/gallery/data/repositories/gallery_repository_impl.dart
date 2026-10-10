import 'package:photo_manager_app/features/encrypted_media/domain/repositories/file_key_repository.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/pending_files.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';


class GalleryRepositoryImpl implements GalleryRepository {

  final GalleryRemoteDataSource remoteDataSource;
  final FileKeyRepository fileKeyRepository;
  GalleryRepositoryImpl(this.remoteDataSource, this.fileKeyRepository);
  
  @override
  Future<GalleryPage> getFiles({
    required int page, 
    required int pageSize, 
    required FileFilter filter
  }) async {
    
    final result = await remoteDataSource.getFiles(
      page: page, 
      pageSize: pageSize,
      type: _getTypeParam(filter),
      status: _getStatusParam(filter),
      favorite: filter.onlyFavorites
    );
    // The keys of the files, to decrypt their thumbnails and originals
    fileKeyRepository.remember(result.files.whereType<GalleryFileModel>().map((file) => file.encryptedRef).nonNulls);
    return result;
  }
  
  @override
  Future<PendingFiles> getPendingFileIds({FileType? type, String? folderId}) async {
    return await remoteDataSource.getPendingFileIds(type: type?.toApiString(), folderId: folderId);
  }

  String? _getTypeParam(FileFilter filter) {
    return filter.fileType?.toApiString();
  }
  
  String? _getStatusParam(FileFilter filter) {
    return filter.fileStatus?.toApiString();
  }
}