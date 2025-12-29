import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';

import '../../domain/entities/manage_folder.dart';


class FileManagementRepositoryImpl implements FileManagementRepository {

  final FileManagementRemoteDataSource remoteDataSource;
  FileManagementRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<String>> manageFiles(List<String> fileIds, ManageAction action) async {
    final request = ManageFileRequestModel.fromDomain(fileIds, action);
    return await remoteDataSource.manageFiles(request);
  }

  @override
  Future<List<ManageFolder>> getFolders() async {
    final folderModels = await remoteDataSource.getFolders();
    return folderModels.map((model) => model as ManageFolder).toList();
  }
}