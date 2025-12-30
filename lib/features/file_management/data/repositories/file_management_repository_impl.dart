import 'package:photo_manager_app/core/database/app_database.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_deletion_local_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_file_result.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';

import '../../domain/entities/manage_folder.dart';


class FileManagementRepositoryImpl implements FileManagementRepository {

  final FileManagementRemoteDataSource remoteDataSource;
  final FileDeletionLocalDataSource deletionLocalDataSource;
  final AppDatabase database;

  FileManagementRepositoryImpl({
    required this.remoteDataSource,
    required this.deletionLocalDataSource,
    required this.database
  });

  @override
  Future<ManageFileResult> manageFiles(List<String> fileIds, ManageAction action) async {
    final request = ManageFileRequestModel.fromDomain(fileIds, action);
    final response =  await remoteDataSource.manageFiles(request);
    return ManageFileResult(successfulIds: response.successfulIds, failedIds: response.failedIds);
  }

  @override
  Future<List<ManageFolder>> getFolders() async {
    final folderModels = await remoteDataSource.getFolders();
    return folderModels.map((model) => model as ManageFolder).toList();
  }

  @override
  Future<List<String>> deleteLocalFiles(List<String> serverIds) async {

    try {

      final mappings = await database.getFileMappings(serverIds);

      if (mappings.isEmpty) {
        return [];
      }

      final localIds = mappings.map((m) => m['local_id'] as String).toList();
      final deletedLocalIds = await deletionLocalDataSource.deleteFiles(localIds);
      final successfulServerIds = <String>[];

      for (final mapping in mappings) {
        final localId = mapping['local_id'] as String;
        final serverId = mapping['server_id'] as String;

        if (deletedLocalIds.contains(localId)) {
          await database.deleteMapping(serverId);
          successfulServerIds.add(serverId);
        }
      }

      return successfulServerIds;
    } catch (e) {
      return [];
    }
  }
}