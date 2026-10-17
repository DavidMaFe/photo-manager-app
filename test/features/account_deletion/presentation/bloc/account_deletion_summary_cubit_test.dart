import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/account_deletion/domain/entities/account_deletion_summary.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/get_account_deletion_summary_use_case.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/account_deletion_summary_cubit.dart';

class MockGetAccountDeletionSummaryUseCase extends Mock implements GetAccountDeletionSummaryUseCase {}

void main() {
  late MockGetAccountDeletionSummaryUseCase getSummary;
  const summary = AccountDeletionSummary(files: 1248, storedBytes: 4096, albums: 12, devices: 3);

  setUp(() => getSummary = MockGetAccountDeletionSummaryUseCase());

  group('AccountDeletionSummaryCubit', () {
    test('should start loading', () {
      expect(AccountDeletionSummaryCubit(getSummary: getSummary).state, isA<AccountDeletionSummaryLoading>());
    });

    blocTest<AccountDeletionSummaryCubit, AccountDeletionSummaryState>(
      'should emit [Loading, Loaded] with the summary of the server',
      build: () {
        when(() => getSummary()).thenAnswer((_) async => summary);
        return AccountDeletionSummaryCubit(getSummary: getSummary);
      },
      act: (cubit) => cubit.load(),
      expect: () => [
        isA<AccountDeletionSummaryLoading>(),
        isA<AccountDeletionSummaryLoaded>().having((s) => s.summary, 'summary', summary),
      ],
    );

    blocTest<AccountDeletionSummaryCubit, AccountDeletionSummaryState>(
      'should emit [Loading, Error] without network',
      build: () {
        when(() => getSummary()).thenThrow(const SocketException('offline'));
        return AccountDeletionSummaryCubit(getSummary: getSummary);
      },
      act: (cubit) => cubit.load(),
      expect: () => [isA<AccountDeletionSummaryLoading>(), isA<AccountDeletionSummaryError>()],
    );
  });
}
