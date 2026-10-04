import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';

import '../entities/manage_file_result.dart';


abstract class FileManagementRepository {
  Future<ManageFileResult> manageFiles(List<String> fileIds, ManageAction action);
  Future<List<ManageFolder>> getFolders();
  Future<ManageFolder> createFolder(String name);
  Future<List<String>> deleteLocalFiles(List<String> serverIds);
}