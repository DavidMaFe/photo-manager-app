import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/favorites/data/models/favorite_result_model.dart';
import 'package:photo_manager_app/features/favorites/domain/entities/favorite_result.dart';

void main() {
  group('FavoriteResultModel', () {
    test('should parse numeric IDs as strings', () {
      // Act
      final model = FavoriteResultModel.fromJson(const {'updated': [1, 2], 'failed': [3]});

      // Assert
      expect(model, isA<FavoriteResult>());
      expect(model.updatedIds, ['1', '2']);
      expect(model.failedIds, ['3']);
      expect(model.hasFailures, isTrue);
      expect(model.allFailed, isFalse);
    });

    test('should default to empty lists', () {
      // Act
      final model = FavoriteResultModel.fromJson(const {});

      // Assert
      expect(model.updatedIds, isEmpty);
      expect(model.failedIds, isEmpty);
      expect(model.hasFailures, isFalse);
    });

    test('should report when every file failed', () {
      expect(const FavoriteResult(updatedIds: [], failedIds: ['1']).allFailed, isTrue);
    });

    test('should serialize to JSON', () {
      expect(
        const FavoriteResultModel(updatedIds: ['1'], failedIds: []).toJson(),
        {'updated': ['1'], 'failed': []},
      );
    });
  });
}
