import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/otp_field.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/register_page.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_code_step.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_details_step.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_email_step.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockRegistrationEmailCubit extends MockCubit<RegistrationEmailState> implements RegistrationEmailCubit {}

void main() {
  late MockAuthBloc authBloc;
  late MockRegistrationEmailCubit cubit;

  const email = 'ana@example.com';

  setUp(() {
    authBloc = MockAuthBloc();
    when(() => authBloc.state).thenReturn(NotAuthenticated());
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    cubit = MockRegistrationEmailCubit();
    when(() => cubit.sendCode(any())).thenAnswer((_) async {});
    when(() => cubit.verifyCode(any())).thenAnswer((_) async {});
    when(() => cubit.resendCode()).thenAnswer((_) async {});
  });

  Future<void> pumpSteps(WidgetTester tester, RegistrationEmailState state,
      {Stream<RegistrationEmailState>? states}) async {
    setUpCustomScreenSize(tester, 390, 844);
    whenListen(cubit, states ?? const Stream<RegistrationEmailState>.empty(), initialState: state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<RegistrationEmailCubit>.value(value: cubit),
      ],
      child: const RegisterSteps(),
    ));
  }

  group('RegisterSteps', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should start asking for the email', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState());

      expect(find.byType(RegisterEmailStep), findsOneWidget);
      expect(find.text('Step 1 of 3'), findsOneWidget);
      expect(find.text("First we verify your email: we'll send you a 6-digit code."), findsOneWidget);
    });

    testWidgets('should send the code to the email typed', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState());

      await tester.enterText(find.byType(TextFormField), ' $email ');
      await tester.tap(find.widgetWithText(AppButton, 'Send code'));
      await tester.pump();

      verify(() => cubit.sendCode(' $email ')).called(1);
    });

    testWidgets('should ask for the code sent to the email', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email));

      expect(find.byType(RegisterCodeStep), findsOneWidget);
      expect(find.text('Step 2 of 3'), findsOneWidget);
      expect(find.textContaining(email, findRichText: true), findsOneWidget);
      expect(find.byType(OtpField), findsOneWidget);
    });

    testWidgets('should verify the code once its 6 digits are typed', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email));

      await tester.enterText(find.byType(EditableText), '482913');
      await tester.pump();

      verify(() => cubit.verifyCode('482913')).called(1);
    });

    testWidgets('should ask for the rest of the data with the verified email and code', (tester) async {
      await pumpSteps(tester,
          const RegistrationEmailState(step: RegistrationStep.details, email: email, code: '482913'));

      final details = tester.widget<RegisterDetailsStep>(find.byType(RegisterDetailsStep));
      expect(details.email, email);
      expect(details.emailCode, '482913');
    });

    testWidgets('should go from step to step when the cubit moves on', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(),
          states: Stream.value(const RegistrationEmailState(step: RegistrationStep.code, email: email)));
      await tester.pump();

      expect(find.byType(RegisterCodeStep), findsOneWidget);
    });

    // ==================== BUSINESS LOGIC TESTS ====================

    testWidgets('should tell when the email already has an account and offer to log in', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(email: email, emailTaken: true));

      expect(find.byKey(const ValueKey('register-email-taken')), findsOneWidget);
      expect(find.text('This email already has an account.'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Sign In'), findsOneWidget);
    });

    testWidgets('should not resend the code until a minute has passed', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email));

      final resend = find.byKey(const ValueKey('register-resend-code'));
      expect(tester.widget<TextButton>(resend).onPressed, isNull);

      await tester.pump(const Duration(seconds: RegisterCodeStep.resendCooldownSeconds));
      await tester.tap(resend);
      await tester.pump();

      verify(() => cubit.resendCode()).called(1);
    });

    testWidgets('should go back to change the email', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email));

      await tester.tap(find.byKey(const ValueKey('register-change-email')));
      await tester.pump();

      verify(() => cubit.changeEmail()).called(1);
    });

    testWidgets('should say when a new code was sent', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email),
          states: Stream.value(
              const RegistrationEmailState(step: RegistrationStep.code, email: email, codeResent: true)));
      await tester.pump();

      expect(find.text('Code resent successfully'), findsOneWidget);
      verify(() => cubit.codeResentShown()).called(1);
    });

    // ==================== ERROR TESTS ====================

    testWidgets('should show the error of a wrong code', (tester) async {
      final failure = ValidationFailure(code: 'INVALID_EMAIL_CODE', errorResponse: ErrorResponseModel(
          code: 'INVALID_EMAIL_CODE', message: 'The code is not valid', timestamp: '2026-10-20T10:00:00'));
      await pumpSteps(tester, const RegistrationEmailState(step: RegistrationStep.code, email: email),
          states: Stream.value(
              RegistrationEmailState(step: RegistrationStep.code, email: email, failure: failure)));
      await tester.pump();

      expect(find.text('The code is not valid'), findsOneWidget);
      expect(tester.widget<OtpField>(find.byType(OtpField)).hasError, isTrue);
    });

    // ==================== LOADING STATE TESTS ====================

    testWidgets('should wait while the code is being sent', (tester) async {
      await pumpSteps(tester, const RegistrationEmailState(email: email, loading: true));

      expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
      expect(tester.widget<TextFormField>(find.byType(TextFormField)).enabled, isFalse);
    });
  });
}
