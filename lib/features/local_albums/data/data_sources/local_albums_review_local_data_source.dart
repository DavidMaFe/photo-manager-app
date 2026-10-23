import 'package:shared_preferences/shared_preferences.dart';

/// Whether each account already reviewed the albums of this device («Tus álbumes», ROADMAP-local-albums.md).
abstract class LocalAlbumsReviewLocalDataSource {
  Future<bool> isReviewed(String userId);
  Future<void> markReviewed(String userId);
}

class LocalAlbumsReviewLocalDataSourceImpl implements LocalAlbumsReviewLocalDataSource {
  static const String _keyPrefix = 'LOCAL_ALBUMS_REVIEWED_';

  final SharedPreferences sharedPreferences;

  LocalAlbumsReviewLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<bool> isReviewed(String userId) async => sharedPreferences.getBool('$_keyPrefix$userId') ?? false;

  @override
  Future<void> markReviewed(String userId) async {
    await sharedPreferences.setBool('$_keyPrefix$userId', true);
  }
}
