import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/local_albums/data/data_sources/local_albums_review_local_data_source.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalAlbumsReviewLocalDataSource', () {
    test('should remember the review of each account', () async {
      SharedPreferences.setMockInitialValues({});
      final dataSource = LocalAlbumsReviewLocalDataSourceImpl(sharedPreferences: await SharedPreferences.getInstance());

      expect(await dataSource.isReviewed('user-1'), isFalse);
      await dataSource.markReviewed('user-1');

      expect(await dataSource.isReviewed('user-1'), isTrue);
      expect(await dataSource.isReviewed('user-2'), isFalse);
    });
  });
}
