import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_failures.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/features/account_security/domain/use_cases/recovery_phrase_use_cases.dart';
import 'package:photo_manager_app/features/account_security/presentation/bloc/verify_recovery_phrase_bloc.dart';

class MockVerifyRecoveryWordsUseCase extends Mock implements VerifyRecoveryWordsUseCase {}

class MockRecoveryReminderUseCase extends Mock implements RecoveryReminderUseCase {}

void main() {
  late MockVerifyRecoveryWordsUseCase verifyWords;
  late MockRecoveryReminderUseCase reminders;
  final words = List.filled(24, 'abandon');
  const typed = {2: 'abandon', 9: 'abandon', 20: 'abandon'};

  setUpAll(() => registerFallbackValue(RecoveryPhraseLanguage.english));

  setUp(() {
    verifyWords = MockVerifyRecoveryWordsUseCase();
    reminders = MockRecoveryReminderUseCase();
    when(() => reminders.completeVerification()).thenAnswer((_) async {});
    when(() => verifyWords.positionsToAsk()).thenReturn([2, 9, 20]);
  });

  VerifyRecoveryPhraseBloc build() => VerifyRecoveryPhraseBloc(verifyUseCase: verifyWords, reminderUseCase: reminders);

  group('VerifyRecoveryPhraseBloc', () {
    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should ask for 3 words when this device keeps the recovery key',
      build: () {
        when(() => verifyWords.hasLocalCopy()).thenAnswer((_) async => true);
        return build();
      },
      act: (bloc) => bloc.add(VerifyRecoveryPhraseStarted()),
      expect: () => [isA<VerifyAskWords>().having((s) => s.positions, 'positions', [2, 9, 20])],
    );

    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should ask for the full phrase without a local copy',
      build: () {
        when(() => verifyWords.hasLocalCopy()).thenAnswer((_) async => false);
        return build();
      },
      act: (bloc) => bloc.add(VerifyRecoveryPhraseStarted()),
      expect: () => [isA<VerifyAskFullPhrase>()],
    );

    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should move the reminders forward when the words are right',
      build: () {
        when(() => verifyWords.checkWords(typed, RecoveryPhraseLanguage.spanish)).thenAnswer((_) async => true);
        return build();
      },
      act: (bloc) => bloc.add(VerifyWordsSubmitted(typed, RecoveryPhraseLanguage.spanish)),
      expect: () => [
        isA<VerifyAskWords>().having((s) => s.working, 'working', true),
        isA<VerifyRecoveryPhraseSuccess>(),
      ],
      verify: (_) => verify(() => reminders.completeVerification()).called(1),
    );

    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should ask again, keeping the reminders, when a word is wrong',
      build: () {
        when(() => verifyWords.checkWords(any(), any())).thenAnswer((_) async => false);
        return build();
      },
      act: (bloc) => bloc.add(VerifyWordsSubmitted(typed, RecoveryPhraseLanguage.english)),
      expect: () => [
        isA<VerifyAskWords>().having((s) => s.working, 'working', true),
        isA<VerifyAskWords>().having((s) => s.wrong, 'wrong', true),
      ],
      verify: (_) => verifyNever(() => reminders.completeVerification()),
    );

    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should succeed with the full phrase checked against the server',
      build: () {
        when(() => verifyWords.verifyFullPhrase(words)).thenAnswer((_) async {});
        return build();
      },
      act: (bloc) => bloc.add(VerifyFullPhraseSubmitted(words)),
      expect: () => [
        isA<VerifyAskFullPhrase>().having((s) => s.working, 'working', true),
        isA<VerifyRecoveryPhraseSuccess>(),
      ],
      verify: (_) => verify(() => reminders.completeVerification()).called(1),
    );

    blocTest<VerifyRecoveryPhraseBloc, VerifyRecoveryPhraseState>(
      'should show the failure when the full phrase belongs to another key',
      build: () {
        when(() => verifyWords.verifyFullPhrase(any())).thenThrow(const RecoveryPhraseMismatchFailure());
        return build();
      },
      act: (bloc) => bloc.add(VerifyFullPhraseSubmitted(words)),
      expect: () => [
        isA<VerifyAskFullPhrase>(),
        isA<VerifyAskFullPhrase>().having((s) => s.failure, 'failure', isA<RecoveryPhraseMismatchFailure>()),
      ],
    );
  });
}
