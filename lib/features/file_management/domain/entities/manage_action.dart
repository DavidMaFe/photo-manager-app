import 'package:equatable/equatable.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';


class ManageAction extends Equatable {

  final ServerAction serverAction;
  final String? folderId;
  final String? folderName;
  final bool keepOnDevice;

  const ManageAction({
    required this.serverAction,
    this.folderId,
    this.folderName,
    required this.keepOnDevice
  });

  bool isValid() {
    switch (serverAction) {
      case ServerAction.folder:
        return folderId != null;
      case ServerAction.newFolder:
        return folderName != null && folderName!.trim().isNotEmpty;
      case ServerAction.save:
      case ServerAction.delete:
        return true;
    }
  }

  @override
  List<Object?> get props => [serverAction, folderId, folderName, keepOnDevice];
}