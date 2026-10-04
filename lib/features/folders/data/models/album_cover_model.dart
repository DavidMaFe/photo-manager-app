import '../../domain/entities/album_cover.dart';


class AlbumCoverModel extends AlbumCover {

  const AlbumCoverModel({
    required super.fileId,
    required super.position,
    required super.sourceFolderId,
    required super.sourceFolderName,
    super.sourceFolderPath,
  });

  factory AlbumCoverModel.fromJson(Map<String, dynamic> json) {
    final path = json['sourceFolderPath'] as List<dynamic>? ?? const [];
    return AlbumCoverModel(
      fileId: json['fileId'].toString(),
      position: json['position'] as int? ?? 0,
      sourceFolderId: json['sourceFolderId'].toString(),
      sourceFolderName: json['sourceFolderName'] as String? ?? '',
      sourceFolderPath: path.map((name) => name.toString()).toList(),
    );
  }

  static List<AlbumCover> listFromJson(Object? value) {
    final covers = value is List
        ? value.map((json) => AlbumCoverModel.fromJson(json as Map<String, dynamic>)).toList()
        : <AlbumCover>[];
    return covers..sort((a, b) => a.position.compareTo(b.position));
  }

  Map<String, dynamic> toJson() {
    return {
      'fileId': fileId,
      'position': position,
      'sourceFolderId': sourceFolderId,
      'sourceFolderName': sourceFolderName,
      'sourceFolderPath': sourceFolderPath,
    };
  }
}
