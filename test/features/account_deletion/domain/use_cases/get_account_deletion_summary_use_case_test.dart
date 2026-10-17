import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/repositories/account_deletion_repository.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/get_account_deletion_summary_use_case.dart';

class MockAccountDeletionRepository extends Mock implements AccountDeletionRepository {}

void main() {
  group('GetAccountDeletionSummaryUseCase', () {
    test('should give the summary of the repository', () async {
      final repository = MockAccountDeletionRepository();
      const summary = AccountDeletionSummary(files: 10, storedBytes: 20, albums: 2, devices: 1);
      when(() => repository.getSummary()).thenAnswer((_) async => summary);

      expect(await GetAccountDeletionSummaryUseCase(repository)(), summary);
    });
  });
}
