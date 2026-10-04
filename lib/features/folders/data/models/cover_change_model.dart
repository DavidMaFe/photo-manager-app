import '../../domain/entities/cover_change.dart';


/// Request body of one change of `PUT /api/folder/cover/batch/`.
class CoverChangeModel {

  static Map<String, dynamic> toJson(CoverChange change) {
    return {
      'folderId': change.folderId,
      'action': change.action.name,
      if (change.replaceFileId != null) 'replaceFileId': change.replaceFileId,
    };
  }
}
