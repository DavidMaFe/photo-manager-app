import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/locked_account_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/locked_account_bloc.dart';

import '../../../../fixtures/e2ee_test_data.dart';

class MockGetLockedAccountStatusUseCase extends Mock implements GetLockedAccountStatusUseCase {}

class MockUnlockWithRecoveryPhraseUseCase extends Mock implements UnlockWithRecoveryPhraseUseCase {}

class MockUnlockWithDeviceKeysUseCase extends Mock implements UnlockWithDeviceKeysUseCase {}

class MockCreateNewKeyVersionUseCase extends Mock implements CreateNewKeyVersionUseCase {}

void main() {
  late MockGetLockedAccountStatusUseCase getStatus;
  late MockUnlockWithRecoveryPhraseUseCase unlockWithWords;
  late MockUnlockWithDeviceKeysUseCase unlockWithDevice;
  late MockCreateNewKeyVersionUseCase createNewKey;

  const password = 'the password';
  final words = List.filled(24, 'abandon');

  LockedAccountStatus status({required bool accountLocked}) => LockedAccountStatus(
        keys: AccountKeys(accountLocked: accountLocked, versions: [
          E2eeTestData.keyVersion(version: 1, state: KeyState.locked),
          if (!accountLocked) E2eeTestData.keyVersion(version: 2),
        ]),
        versionsHeldOnDevice: const [1],
      );

  final locked = status(accountLocked: true);

  setUpAll(() => registerFallbackValue(RecoveryPhraseLanguage.english));

  setUp(() {
    getStatus = MockGetLockedAccountStatusUseCase();
    unlockWithWords = MockUnlockWithRecoveryPhraseUseCase();
    unlockWithDevice = MockUnlockWithDeviceKeysUseCase();
    createNewKey = MockCreateNewKeyVersionUseCase();
    when(() => getStatus()).thenAnswer((_) async => locked);
  });

  LockedAccountBloc build() => LockedAccountBloc(
        getStatusUseCase: getStatus,
        unlockWithRecoveryPhraseUseCase: unlockWithWords,
        unlockWithDeviceKeysUseCase: unlockWithDevice,
        createNewKeyVersionUseCase: createNewKey,
      );

  group('LockedAccountBloc', () {
    test('initial state should be LockedAccountLoading', () {
      expect(build().state, isA<LockedAccountLoading>());
    });

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should load the status of the locked account',
      build: build,
      act: (bloc) => bloc.add(LockedAccountStatusRequested()),
      expect: () => [
        isA<LockedAccountLoading>(),
        isA<LockedAccountLoaded>().having((s) => s.status, 'status', locked).having((s) => s.working, 'working', false),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should emit an error without status when the status cannot be loaded',
      build: () {
        when(() => getStatus()).thenThrow(Exception('network'));
        return build();
      },
      act: (bloc) => bloc.add(LockedAccountStatusRequested()),
      expect: () => [
        isA<LockedAccountLoading>(),
        isA<LockedAccountError>().having((s) => s.status, 'status', isNull),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should unlock with the 24 words and tell that the account is usable again',
      build: () {
        when(() => unlockWithWords(password: password, words: words)).thenAnswer((_) async => [1]);
        return build();
      },
      act: (bloc) async {
        bloc.add(LockedAccountStatusRequested());
        await Future<void>.delayed(Duration.zero);
        when(() => getStatus()).thenAnswer((_) async => status(accountLocked: false));
        bloc.add(UnlockWithWordsRequested(password: password, words: words));
      },
      skip: 2,
      expect: () => [
        isA<LockedAccountLoaded>().having((s) => s.working, 'working', true),
        isA<LockedAccountUnlocked>()
            .having((s) => s.versions, 'versions', [1])
            .having((s) => s.accountUsable, 'usable', isTrue),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should unlock with the keys of this device and tell when the account stays locked',
      build: () {
        when(() => unlockWithDevice(password: password)).thenAnswer((_) async => [1]);
        return build();
      },
      act: (bloc) => bloc.add(UnlockWithDeviceRequested(password: password)),
      expect: () => [
        isA<LockedAccountUnlocked>().having((s) => s.accountUsable, 'usable', isFalse),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should keep the status in the error so the page can try again',
      build: () {
        when(() => unlockWithWords(password: any(named: 'password'), words: any(named: 'words')))
            .thenThrow(const RecoveryPhraseMismatchFailure());
        return build();
      },
      act: (bloc) async {
        bloc.add(LockedAccountStatusRequested());
        await Future<void>.delayed(Duration.zero);
        bloc.add(UnlockWithWordsRequested(password: password, words: words));
      },
      skip: 3,
      expect: () => [
        isA<LockedAccountError>()
            .having((s) => s.failure, 'failure', isA<RecoveryPhraseMismatchFailure>())
            .having((s) => s.status, 'status', locked),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should create a new key and give its 24 words',
      build: () {
        when(() => createNewKey(password: password, language: RecoveryPhraseLanguage.spanish))
            .thenAnswer((_) async => words);
        return build();
      },
      act: (bloc) => bloc.add(NewKeyRequested(password: password, language: RecoveryPhraseLanguage.spanish)),
      expect: () => [
        isA<LockedAccountNewKeyCreated>().having((s) => s.words, 'words', words),
      ],
    );

    blocTest<LockedAccountBloc, LockedAccountState>(
      'should emit an error when the new key cannot be created',
      build: () {
        when(() => createNewKey(password: any(named: 'password'), language: any(named: 'language')))
            .thenThrow(Exception('network'));
        return build();
      },
      act: (bloc) => bloc.add(NewKeyRequested(password: password, language: RecoveryPhraseLanguage.english)),
      expect: () => [isA<LockedAccountError>()],
    );
  });
}
