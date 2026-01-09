import 'package:photo_manager_app/features/file_management/domain/entities/manage_folder.dart';


class ManageFolderModel extends ManageFolder {

  const ManageFolderModel({
    required super.id,
    required super.name,
    required super.fileCount,
    required super.createdAt
  });

  factory ManageFolderModel.fromJson(Map<String, dynamic> json) {
    return ManageFolderModel(
      id: json['id'].toString(),
      name: json['name'] as String,
      fileCount: json['filesQuantity'],
      createdAt: DateTime.parse(json['createdAt'] as String)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'filesQuantity': fileCount,
      'createdAt': createdAt
    };
  }

  factory ManageFolderModel.fromEntity(ManageFolder folder) {
    return ManageFolderModel(
        id: folder.id,
        name: folder.name,
        fileCount: folder.fileCount,
        createdAt: folder.createdAt
    );
  }
}