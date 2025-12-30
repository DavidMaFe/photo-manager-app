
import 'package:photo_manager/photo_manager.dart';

abstract class FileDeletionLocalDataSource {
  Future<bool> deleteFile(String localId);
  Future<List<String>> deleteFiles(List<String> localIds);
}


class FileDeletionLocalDataSourceImpl implements FileDeletionLocalDataSource {

  @override
  Future<bool> deleteFile(String localId) async {

    try {

      final asset = await AssetEntity.fromId(localId);
      if (asset == null) {
        return true;
      }

      final result = await PhotoManager.editor.deleteWithIds([asset.id]);
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<List<String>> deleteFiles(List<String> localIds) async {

    final successfullyDeleted = <String>[];
    try {

      final assets = await Future.wait(
        localIds.map((id) => AssetEntity.fromId(id))
      );

      final validAssets = assets.where((asset) => asset != null).cast<AssetEntity>().toList();
      if (validAssets.isEmpty) return successfullyDeleted;

      final deletedIds = await PhotoManager.editor.deleteWithIds(
        validAssets.map((asset) => asset.id).toList()
      );

      for (int i = 0; i < validAssets.length; i++) {
        if (deletedIds.contains(validAssets[i].id)) {
          successfullyDeleted.add(localIds[i]);
        }
      }

    } catch (e) {
      // Do nothing
    }

    return successfullyDeleted;
  }
}