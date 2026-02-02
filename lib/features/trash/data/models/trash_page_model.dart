import 'package:photo_manager_app/features/trash/data/models/trash_file_model.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';

class TrashPageModel extends TrashPage {
  const TrashPageModel({
    required super.files,
    required super.currentPage,
    required super.pageSize,
    required super.hasNext,
  });

  factory TrashPageModel.fromJson(
    Map<String, dynamic> json, {
    required int currentPage,
    required int pageSize,
  }) {
    final filesList = (json['files'] as List)
        .map((fileJson) =>
            TrashFileModel.fromJson(fileJson as Map<String, dynamic>))
        .toList();

    return TrashPageModel(
      files: filesList,
      currentPage: currentPage,
      pageSize: pageSize,
      hasNext: json['hasNext'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'files': files
          .map((file) => TrashFileModel.fromEntity(file).toJson())
          .toList(),
      'currentPage': currentPage,
      'pageSize': pageSize,
      'hasNext': hasNext,
    };
  }

  factory TrashPageModel.fromEntity(TrashPage page) {
    return TrashPageModel(
      files: page.files,
      currentPage: page.currentPage,
      pageSize: page.pageSize,
      hasNext: page.hasNext,
    );
  }
}
