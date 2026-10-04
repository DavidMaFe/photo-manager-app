import '../../domain/entities/folder_covers.dart';
import 'album_cover_model.dart';


class FolderCoversModel extends FolderCovers {

  const FolderCoversModel({required super.folderId, required super.covers});

  factory FolderCoversModel.fromJson(Map<String, dynamic> json) {
    return FolderCoversModel(
      folderId: json['folderId'].toString(),
      covers: AlbumCoverModel.listFromJson(json['covers']),
    );
  }
}
