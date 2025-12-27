import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';


class GalleryRepositoryImpl implements GalleryRepository {

  final GalleryRemoteDataSource remoteDataSource;
  GalleryRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<GalleryPage> getFiles({
    required int page, 
    required int pageSize, 
    required FileFilter filter
  }) async {
    
    return await remoteDataSource.getFiles(
      page: page, 
      pageSize: pageSize,
      type: _getTypeParam(filter),
      status: _getStatusParam(filter)
    );
  }
  
  String? _getTypeParam(FileFilter filter) {
    return filter.fileType?.toApiString();
  }
  
  String? _getStatusParam(FileFilter filter) {
    return filter.fileStatus?.toApiString();
  }
}