import '../../domain/entities/cover_target.dart';
import 'album_cover_model.dart';


class CoverTargetModel extends CoverTarget {

  const CoverTargetModel({
    required super.folderId,
    required super.name,
    required super.depth,
    required super.containsDirectly,
    super.covers,
  });

  factory CoverTargetModel.fromJson(Map<String, dynamic> json) {
    return CoverTargetModel(
      folderId: json['folderId'].toString(),
      name: json['name'] as String? ?? '',
      depth: json['depth'] as int? ?? 0,
      containsDirectly: json['containsDirectly'] as bool? ?? false,
      covers: AlbumCoverModel.listFromJson(json['covers']),
    );
  }
}
