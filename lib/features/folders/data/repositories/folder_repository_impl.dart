import 'package:photo_manager_app/features/folders/data/data_sources/folder_remote_data_source.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder_content.dart';
import 'package:photo_manager_app/features/folders/domain/repositories/folder_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

import '../../domain/entities/folder.dart';


class FolderRepositoryImpl implements FolderRepository {

  final FolderRemoteDataSource remoteDataSource;
  const FolderRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Folder>> getFolders({String? parentFolderId}) async {
    return await remoteDataSource.getFolders(parentFolderId: parentFolderId);
  }

  @override
  Future<FolderContent> getFolderContent({
    required String folderId,
    int page = 0,
    int pageSize = 50,
    FileFilter filter = FileFilter.all
  }) async {
    return await remoteDataSource.getFolderContent(
      folderId: folderId,
      page: page,
      pageSize: pageSize,
      fileType: _getTypeParam(filter),
      status: _getStatusParam(filter)
    );
  }

  @override
  Future<Folder> createFolder({required String name, String? parentFolderId}) async {
    return await remoteDataSource.createFolder(name: name, parentFolderId: parentFolderId);
  }

  @override
  Future<Folder> renameFolder({required String folderId, required String newName}) async {
    return await remoteDataSource.renameFolder(folderId: folderId, newName: newName);
  }

  @override
  Future<void> deleteFolder({required String folderId}) async {
    await remoteDataSource.deleteFolder(folderId: folderId);
  }

  String? _getTypeParam(FileFilter filter) {
    return filter.fileType?.toApiString();
  }

  String? _getStatusParam(FileFilter filter) {
    return filter.fileStatus?.toApiString();
  }
}