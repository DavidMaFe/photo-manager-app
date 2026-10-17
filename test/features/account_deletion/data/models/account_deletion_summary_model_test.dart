import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/account_deletion/data/models/account_deletion_summary_model.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';

void main() {
  group('AccountDeletionSummaryModel', () {
    group('fromJson', () {
      test('should read the counts and the stored bytes', () {
        final model = AccountDeletionSummaryModel.fromJson(
            const {'files': 1248, 'storedBytes': 13314398617, 'albums': 12, 'devices': 3});

        expect(model.props, const AccountDeletionSummary(files: 1248, storedBytes: 13314398617, albums: 12, devices: 3).props);
      });

      test('should read missing values as zero', () {
        final model = AccountDeletionSummaryModel.fromJson(const {});

        expect(model.props, const AccountDeletionSummary(files: 0, storedBytes: 0, albums: 0, devices: 0).props);
      });
    });

    test('should write the same JSON it reads', () {
      final json = {'files': 3, 'storedBytes': 1024, 'albums': 2, 'devices': 1};

      expect(AccountDeletionSummaryModel.fromJson(json).toJson(), json);
    });
  });
}
