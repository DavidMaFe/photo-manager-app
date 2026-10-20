import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/request_registration_code_use_case.dart';
import 'package:photo_manager_app/features/auth/domain/use_cases/verify_registration_code_use_case.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';

class MockRequestRegistrationCodeUseCase extends Mock implements RequestRegistrationCodeUseCase {}

class MockVerifyRegistrationCodeUseCase extends Mock implements VerifyRegistrationCodeUseCase {}

ApiException _apiError(String code) =>
    ApiException(ErrorResponseModel(code: code, message: code, timestamp: '2026-10-20T10:00:00'));

void main() {
  late MockRequestRegistrationCodeUseCase requestCode;
  late MockVerifyRegistrationCodeUseCase verifyCode;

  const email = 'ana@example.com';
  const wait = Duration(milliseconds: 900);

  setUp(() {
    requestCode = MockRequestRegistrationCodeUseCase();
    verifyCode = MockVerifyRegistrationCodeUseCase();
    when(() => requestCode(any())).thenAnswer((_) async {});
    when(() => verifyCode(email: any(named: 'email'), code: any(named: 'code'))).thenAnswer((_) async {});
  });

  RegistrationEmailCubit build() => RegistrationEmailCubit(requestCode: requestCode, verifyCode: verifyCode);

  group('RegistrationEmailCubit', () {
    // ==================== SEND CODE ====================

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should go to the code step once the code is sent',
      build: build,
      act: (cubit) => cubit.sendCode(' $email '),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(email: email, loading: true),
        const RegistrationEmailState(step: RegistrationStep.code, email: email),
      ],
      verify: (_) => verify(() => requestCode(email)).called(1),
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should stay in the email step and say the email has an account',
      setUp: () => when(() => requestCode(any())).thenThrow(_apiError('EMAIL_ALREADY_USED')),
      build: build,
      act: (cubit) => cubit.sendCode(email),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(email: email, loading: true),
        const RegistrationEmailState(email: email, emailTaken: true),
      ],
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should keep the failure of any other error',
      setUp: () => when(() => requestCode(any())).thenThrow(_apiError('TOO_MANY_EMAIL_CODES')),
      build: build,
      act: (cubit) => cubit.sendCode(email),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(email: email, loading: true),
        isA<RegistrationEmailState>()
            .having((state) => state.step, 'step', RegistrationStep.email)
            .having((state) => state.failure, 'failure', isA<PermissionDeniedFailure>())
            .having((state) => state.loading, 'loading', isFalse),
      ],
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should not send twice at the same time',
      build: build,
      seed: () => const RegistrationEmailState(email: email, loading: true),
      act: (cubit) => cubit.sendCode(email),
      expect: () => const <RegistrationEmailState>[],
      verify: (_) => verifyNever(() => requestCode(any())),
    );

    // ==================== RESEND ====================

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should send a new code to the same email and say it',
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.code, email: email),
      act: (cubit) => cubit.resendCode(),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(step: RegistrationStep.code, email: email, loading: true),
        const RegistrationEmailState(step: RegistrationStep.code, email: email, codeResent: true),
      ],
      verify: (_) => verify(() => requestCode(email)).called(1),
    );

    // ==================== VERIFY ====================

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should go to the last step with the verified code',
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.code, email: email),
      act: (cubit) => cubit.verifyCode('482913'),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(step: RegistrationStep.code, email: email, loading: true),
        const RegistrationEmailState(step: RegistrationStep.details, email: email, code: '482913'),
      ],
      verify: (_) => verify(() => verifyCode(email: email, code: '482913')).called(1),
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should stay in the code step with the failure of a wrong code',
      setUp: () => when(() => verifyCode(email: any(named: 'email'), code: any(named: 'code')))
          .thenThrow(_apiError('INVALID_EMAIL_CODE')),
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.code, email: email),
      act: (cubit) => cubit.verifyCode('000000'),
      wait: wait,
      expect: () => [
        const RegistrationEmailState(step: RegistrationStep.code, email: email, loading: true),
        isA<RegistrationEmailState>()
            .having((state) => state.step, 'step', RegistrationStep.code)
            .having((state) => state.failure, 'failure', isA<ValidationFailure>()),
      ],
    );

    // ==================== GOING BACK ====================

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should go back to the email step keeping the email',
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.details, email: email, code: '482913'),
      act: (cubit) => cubit.changeEmail(),
      expect: () => [const RegistrationEmailState(email: email)],
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should go back to the code step when the registration rejects the code',
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.details, email: email, code: '482913'),
      act: (cubit) => cubit.codeRejected(),
      expect: () => [const RegistrationEmailState(step: RegistrationStep.code, email: email)],
    );

    blocTest<RegistrationEmailCubit, RegistrationEmailState>(
      'should forget the notice of the code sent once shown',
      build: build,
      seed: () => const RegistrationEmailState(step: RegistrationStep.code, email: email, codeResent: true),
      act: (cubit) => cubit.codeResentShown(),
      expect: () => [const RegistrationEmailState(step: RegistrationStep.code, email: email)],
    );
  });
}
