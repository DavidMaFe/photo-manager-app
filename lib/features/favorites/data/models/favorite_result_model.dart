import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';


class FavoriteResultModel extends FavoriteResult {

  const FavoriteResultModel({required super.updatedIds, required super.failedIds});

  /// The backend sends numeric IDs.
  factory FavoriteResultModel.fromJson(Map<String, dynamic> json) {
    return FavoriteResultModel(
      updatedIds: _ids(json['updated']),
      failedIds: _ids(json['failed']),
    );
  }

  static List<String> _ids(Object? value) =>
      value is List ? value.map((id) => id.toString()).toList() : const [];

  Map<String, dynamic> toJson() => {'updated': updatedIds, 'failed': failedIds};
}
