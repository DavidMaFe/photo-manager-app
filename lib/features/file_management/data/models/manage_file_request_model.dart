import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';


class ManageFileRequestModel {

  final List<String> fileIds;
  final String serverAction;
  final String? folderId;
  final String? folderName;
  final bool keepOnDevice;

  const ManageFileRequestModel({
    required this.fileIds,
    required this.serverAction,
    this.folderId,
    this.folderName,
    required this.keepOnDevice
  });

  factory ManageFileRequestModel.fromDomain(List<String> fileIds, ManageAction action) {
    return ManageFileRequestModel(
      fileIds: fileIds,
      serverAction: _mapServerAction(action.serverAction),
      folderId: action.folderId,
      folderName: action.folderName,
      keepOnDevice: action.keepOnDevice
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filesToManage': fileIds,
      'manageAction': serverAction,
      if(folderId != null) 'folderId': folderId,
      if(folderName != null) 'folderName': folderName,
      'keepOnDevice': keepOnDevice
    };
  }

  static String _mapServerAction(ServerAction action) {
    switch(action) {
      case ServerAction.save:
      case ServerAction.folder:
      case ServerAction.newFolder:
        return 'SAVE';
      case ServerAction.delete:
        return 'DELETE';
    }
  }
}