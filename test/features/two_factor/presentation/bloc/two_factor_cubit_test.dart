import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/totp_set_up.dart';
import 'package:photo_manager_app/features/two_factor/domain/entities/two_factor_status.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/disable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/enable_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/get_two_factor_status_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/regenerate_backup_codes_use_case.dart';
import 'package:photo_manager_app/features/two_factor/domain/use_cases/set_up_totp_use_case.dart';
import 'package:photo_manager_app/features/two_factor/presentation/bloc/two_factor_cubit.dart';

class MockGetStatus extends Mock implements GetTwoFactorStatusUseCase {}

class MockSetUp extends Mock implements SetUpTotpUseCase {}

class MockEnable extends Mock implements EnableTotpUseCase {}

class MockDisable extends Mock implements DisableTotpUseCase {}

class MockRegenerate extends Mock implements RegenerateBackupCodesUseCase {}

void main() {
  late MockGetStatus getStatus;
  late MockSetUp setUpUseCase;
  late MockEnable enable;
  late MockDisable disable;
  late MockRegenerate regenerate;

  const off = TwoFactorStatus(totpEnabled: false, backupCodesLeft: 0);
  const on = TwoFactorStatus(totpEnabled: true, backupCodesLeft: 10);
  const totpSetUp = TotpSetUp(secret: 'GEZD', otpauthUri: 'otpauth://totp/x');
  final codes = List.generate(10, (i) => 'abcd$i-efgh$i');
  const wait = Duration(milliseconds: 900);

  ApiException apiError(String code) =>
      ApiException(ErrorResponseModel(code: code, message: 'message', timestamp: '2026-10-20T10:00:00'));

  setUp(() {
    getStatus = MockGetStatus();
    setUpUseCase = MockSetUp();
    enable = MockEnable();
    disable = MockDisable();
    regenerate = MockRegenerate();
  });

  TwoFactorCubit build() => TwoFactorCubit(
      getStatus: getStatus, setUpTotp: setUpUseCase, enableTotp: enable, disableTotp: disable,
      regenerateBackupCodes: regenerate);

  group('TwoFactorCubit', () {
    blocTest<TwoFactorCubit, TwoFactorState>(
      'should load the status',
      build: () {
        when(() => getStatus()).thenAnswer((_) async => off);
        return build();
      },
      act: (cubit) => cubit.load(),
      wait: wait,
      expect: () => [
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.loading),
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.status).having((s) => s.status, 's', off),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should show the error when the status cannot be loaded',
      build: () {
        when(() => getStatus()).thenThrow(Exception('offline'));
        return build();
      },
      act: (cubit) => cubit.load(),
      wait: wait,
      expect: () => [
        isA<TwoFactorState>(),
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.error).having((s) => s.failure, 'f', isNotNull),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should go from the set-up to the backup codes with the right code',
      build: () {
        when(() => setUpUseCase()).thenAnswer((_) async => totpSetUp);
        when(() => enable(any())).thenAnswer((_) async => codes);
        return build();
      },
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: off),
      act: (cubit) async {
        await cubit.startSetUp();
        await cubit.enable('123456');
      },
      expect: () => [
        isA<TwoFactorState>().having((s) => s.working, 'working', isTrue),
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.setUp).having((s) => s.setUp, 's', totpSetUp),
        isA<TwoFactorState>().having((s) => s.working, 'working', isTrue),
        isA<TwoFactorState>()
            .having((s) => s.view, 'view', TwoFactorView.backupCodes)
            .having((s) => s.backupCodes, 'codes', codes),
      ],
      verify: (_) => verify(() => enable('123456')).called(1),
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should stay on the set-up with the failure of a wrong code',
      build: () {
        when(() => enable(any())).thenThrow(apiError('INVALID_TOTP_CODE'));
        return build();
      },
      seed: () => const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp),
      act: (cubit) => cubit.enable('000000'),
      wait: wait,
      expect: () => [
        isA<TwoFactorState>().having((s) => s.working, 'working', isTrue),
        isA<TwoFactorState>()
            .having((s) => s.view, 'view', TwoFactorView.setUp)
            .having((s) => s.setUp, 'setUp', totpSetUp)
            .having((s) => s.failure?.code, 'failure', 'INVALID_TOTP_CODE'),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should go back to the status when the set-up is cancelled',
      build: build,
      seed: () => const TwoFactorState(view: TwoFactorView.setUp, status: off, setUp: totpSetUp),
      act: (cubit) => cubit.cancelSetUp(),
      expect: () => [
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.status).having((s) => s.setUp, 's', isNull),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should turn the app off, reload the status and say it',
      build: () {
        when(() => disable(password: any(named: 'password'), code: any(named: 'code'))).thenAnswer((_) async {});
        when(() => getStatus()).thenAnswer((_) async => off);
        return build();
      },
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: on),
      act: (cubit) => cubit.disable(password: 'secret', code: '123456'),
      wait: wait,
      expect: () => [
        isA<TwoFactorState>().having((s) => s.working, 'working', isTrue),
        isA<TwoFactorState>()
            .having((s) => s.status, 'status', off)
            .having((s) => s.notice, 'notice', TwoFactorNotice.disabled),
      ],
      verify: (_) => verify(() => disable(password: 'secret', code: '123456')).called(1),
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should keep the app on with the failure of a wrong password',
      build: () {
        when(() => disable(password: any(named: 'password'), code: any(named: 'code')))
            .thenThrow(apiError('INCORRECT_PASSWORD'));
        return build();
      },
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: on),
      act: (cubit) => cubit.disable(password: 'wrong', code: '123456'),
      wait: wait,
      expect: () => [
        isA<TwoFactorState>(),
        isA<TwoFactorState>()
            .having((s) => s.status, 'status', on)
            .having((s) => s.failure, 'failure', isA<Failure>()),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should show the new backup codes and forget them once saved',
      build: () {
        when(() => regenerate(password: any(named: 'password'), code: any(named: 'code')))
            .thenAnswer((_) async => codes);
        when(() => getStatus()).thenAnswer((_) async => on);
        return build();
      },
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: on),
      act: (cubit) async {
        await cubit.regenerate(password: 'secret', code: '123456');
        await cubit.backupCodesSaved();
      },
      expect: () => [
        isA<TwoFactorState>().having((s) => s.working, 'working', isTrue),
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.backupCodes),
        isA<TwoFactorState>().having((s) => s.view, 'view', TwoFactorView.loading),
        isA<TwoFactorState>()
            .having((s) => s.view, 'view', TwoFactorView.status)
            .having((s) => s.backupCodes, 'codes', isEmpty),
      ],
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should ignore an action while another one runs',
      build: build,
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: off, working: true),
      act: (cubit) => cubit.startSetUp(),
      expect: () => <TwoFactorState>[],
      verify: (_) => verifyNever(() => setUpUseCase()),
    );

    blocTest<TwoFactorCubit, TwoFactorState>(
      'should forget the failure once shown',
      build: build,
      seed: () => const TwoFactorState(view: TwoFactorView.status, status: on, failure: ValidationFailure()),
      act: (cubit) => cubit.feedbackShown(),
      expect: () => [isA<TwoFactorState>().having((s) => s.failure, 'failure', isNull).having((s) => s.status, 's', on)],
    );
  });
}
