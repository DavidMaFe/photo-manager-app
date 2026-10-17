import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failure_codes.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/account_deletion/domain/use_cases/delete_account_use_case.dart';
import 'package:photo_manager_app/features/account_deletion/presentation/bloc/delete_account_bloc.dart';

class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}

void main() {
  late MockDeleteAccountUseCase deleteAccount;

  setUp(() => deleteAccount = MockDeleteAccountUseCase());

  group('DeleteAccountBloc', () {
    test('should start in the initial state', () {
      expect(DeleteAccountBloc(deleteAccountUseCase: deleteAccount).state, isA<DeleteAccountInitial>());
    });

    blocTest<DeleteAccountBloc, DeleteAccountState>(
      'should emit [Loading, Success] when the account is deleted',
      build: () {
        when(() => deleteAccount(password: any(named: 'password'))).thenAnswer((_) async {});
        return DeleteAccountBloc(deleteAccountUseCase: deleteAccount);
      },
      act: (bloc) => bloc.add(DeleteAccountSubmitted(password: 'the account password')),
      wait: const Duration(milliseconds: 900),
      expect: () => [isA<DeleteAccountLoading>(), isA<DeleteAccountSuccess>()],
      verify: (_) => verify(() => deleteAccount(password: 'the account password')).called(1),
    );

    blocTest<DeleteAccountBloc, DeleteAccountState>(
      'should emit [Loading, Error] with INCORRECT_PASSWORD when the password is wrong',
      build: () {
        when(() => deleteAccount(password: any(named: 'password'))).thenThrow(ApiException(
            ErrorResponseModel(code: FailureCodes.incorrectPassword, message: 'Wrong', timestamp: '')));
        return DeleteAccountBloc(deleteAccountUseCase: deleteAccount);
      },
      act: (bloc) => bloc.add(DeleteAccountSubmitted(password: 'a wrong password')),
      wait: const Duration(milliseconds: 900),
      expect: () => [
        isA<DeleteAccountLoading>(),
        isA<DeleteAccountError>().having((s) => s.failure.code, 'code', FailureCodes.incorrectPassword),
      ],
    );

    blocTest<DeleteAccountBloc, DeleteAccountState>(
      'should emit [Loading, Error] without network',
      build: () {
        when(() => deleteAccount(password: any(named: 'password'))).thenThrow(const SocketException('offline'));
        return DeleteAccountBloc(deleteAccountUseCase: deleteAccount);
      },
      act: (bloc) => bloc.add(DeleteAccountSubmitted(password: 'the account password')),
      wait: const Duration(milliseconds: 900),
      expect: () => [isA<DeleteAccountLoading>(), isA<DeleteAccountError>()],
    );

    test('should keep the loading state at least 800 ms', () async {
      when(() => deleteAccount(password: any(named: 'password'))).thenAnswer((_) async {});
      final bloc = DeleteAccountBloc(deleteAccountUseCase: deleteAccount);
      final stopwatch = Stopwatch()..start();

      bloc.add(DeleteAccountSubmitted(password: 'the account password'));
      await bloc.stream.firstWhere((state) => state is DeleteAccountSuccess);

      expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(DeleteAccountBloc.minimumLoadingDuration - 10));
      await bloc.close();
    });
  });
}
