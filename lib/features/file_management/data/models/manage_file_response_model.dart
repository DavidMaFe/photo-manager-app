
class ManageFileResponseModel {

  final List<String> successfulIds;
  final List<String> failedIds;

  ManageFileResponseModel({required this.successfulIds, required this.failedIds});

  factory ManageFileResponseModel.fromJson(Map<String, dynamic> json) {
    return ManageFileResponseModel(
      successfulIds: (json['successfulFiles'] as List<dynamic>?)
          ?.map((fileId) => fileId.toString())
          .toList() ?? [],

      failedIds: (json['failedFiles'] as List<dynamic>?)
        ?.map((fileId) => fileId.toString())
        .toList() ?? []
    );
  }
}