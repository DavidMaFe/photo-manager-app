import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';
import 'package:photo_manager_app/features/file_management/domain/repositories/file_management_repository.dart';


class GetFileInfoUseCase {

  final FileManagementRepository repository;
  GetFileInfoUseCase(this.repository);

  Future<FileInfo> call(String fileId) async {
    if (fileId.trim().isEmpty) {
      throw Exception('File ID is required');
    }
    return await repository.getFileInfo(fileId);
  }
}
