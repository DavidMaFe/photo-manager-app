import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';


abstract class FileManagementRepository {
  Future<List<String>> manageFiles(List<String> fileIds, ManageAction action);
  Future<List<ManageFolder>> getFolders();
}