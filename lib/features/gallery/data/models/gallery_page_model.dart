import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';


class GalleryPageModel extends GalleryPage {

  const GalleryPageModel({
    required super.files,
    required super.currentPage,
    required super.pageSize,
    required super.hasNext
  });

  factory GalleryPageModel.fromJson(
      Map<String, dynamic> json, {
      required int currentPage,
      required int pageSize
  }) {
    final filesList = (json['files'] as List)
        .map((fileJson) => GalleryFileModel.fromJson(fileJson as Map<String, dynamic>))
        .toList();

    return GalleryPageModel(
      files: filesList,
      currentPage: currentPage,
      pageSize: pageSize,
      hasNext: json['hasNext'] as bool
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'files': files.map((file) => GalleryFileModel.fromEntity(file).toJson()).toList(),
      'currentPage': currentPage,
      'pageSize': pageSize,
      'hasNext': hasNext
    };
  }
}