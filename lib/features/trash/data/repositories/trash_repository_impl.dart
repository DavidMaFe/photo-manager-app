import 'package:photo_manager_app/features/trash/data/data_sources/trash_remote_data_source.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';

class TrashRepositoryImpl implements TrashRepository {
  final TrashRemoteDataSource remoteDataSource;

  TrashRepositoryImpl({required this.remoteDataSource});

  @override
  Future<TrashPage> getTrashFiles({
    required int page,
    required int pageSize,
  }) async {
    return await remoteDataSource.getTrashFiles(
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<void> restoreFiles(List<String> fileIds) async {
    return await remoteDataSource.restoreFiles(fileIds);
  }

  @override
  Future<void> permanentlyDeleteFiles(List<String> fileIds) async {
    return await remoteDataSource.permanentlyDeleteFiles(fileIds);
  }

  @override
  Future<void> emptyTrash() async {
    return await remoteDataSource.emptyTrash();
  }
}
