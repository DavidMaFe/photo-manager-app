
class UploadResultModel {
  final String fileId;

  const UploadResultModel({required this.fileId});

  factory UploadResultModel.fromJson(Map<String, dynamic> json) {
    return UploadResultModel(
      fileId: json['fileId'].toString()
    );
  }
}