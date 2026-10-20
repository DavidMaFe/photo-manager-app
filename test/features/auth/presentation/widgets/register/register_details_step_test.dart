import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/recovery_phrase.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/registration_email_cubit.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/register/register_details_step.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/models/error_response_model.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class MockRegistrationEmailCubit extends MockCubit<RegistrationEmailState> implements RegistrationEmailCubit {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;
  late MockRegistrationEmailCubit mockEmailCubit;

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async {});
    mockEmailCubit = MockRegistrationEmailCubit();
    when(() => mockEmailCubit.state).thenReturn(const RegistrationEmailState(
        step: RegistrationStep.details, email: 'ana@example.com', code: '482913'));
  });

  Future<void> pumpPage(WidgetTester tester, {AuthState? state, Locale locale = const Locale('en')}) async {
    // 390x844 is the design reference size.
    setUpCustomScreenSize(tester, 390, 844);
    if (state != null) when(() => mockAuthBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
        BlocProvider<RegistrationEmailCubit>.value(value: mockEmailCubit),
      ],
      locale: locale,
      child: const RegisterDetailsStep(email: 'ana@example.com', emailCode: '482913'),
    ));
  }

  Finder field(int index) => find.byType(TextFormField).at(index);

  Future<void> acceptLegalTerms(WidgetTester tester) async {
    // The text selection menu of the last field would cover the checkbox
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pump();
    await tester.ensureVisible(find.byKey(const ValueKey('legal-accept-checkbox')));
    await tester.tap(find.byKey(const ValueKey('legal-accept-checkbox')));
    await tester.pump();
  }

  Future<void> tapRegister(WidgetTester tester) async {
    await tester.ensureVisible(find.byType(AppButton));
    await tester.tap(find.byType(AppButton));
    await tester.pump();
  }

  Future<void> fillValidForm(WidgetTester tester) async {
    await tester.enterText(field(0), 'Ana');
    await tester.enterText(field(3), 'long secret 1');
    await tester.enterText(field(4), 'long secret 1');
    await acceptLegalTerms(tester);
  }

  group('RegisterDetailsStep', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the headline, a back bar and all fields', (tester) async {
      // Arrange
      await pumpPage(tester);

      // Assert
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Back up your photos and free up space on your phone.'), findsOneWidget);
      expect(find.byType(SecondaryTopBar), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(5));
      expect(find.text('(optional)', findRichText: true), findsNothing);
      expect(find.textContaining('(optional)', findRichText: true), findsOneWidget);
    });

    testWidgets('should go back to the email step', (tester) async {
      await pumpPage(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.pump();

      verify(() => mockEmailCubit.changeEmail()).called(1);
    });

    testWidgets('should place name and last name on the same row', (tester) async {
      // Arrange
      await pumpPage(tester);

      // Act
      final name = tester.getRect(field(0));
      final surname = tester.getRect(field(1));

      // Assert: side by side (the test font may wrap the longer label).
      expect(surname.top, lessThan(name.bottom));
      expect(surname.left, greaterThan(name.right));
    });

    testWidgets('should need at most a short scroll on the reference screen', (tester) async {
      // Arrange
      await pumpPage(tester);

      // Act
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable).first);

      // Assert: the mandatory acceptance of the terms (Phase 4) added a few lines below the fields
      expect(scrollable.position.maxScrollExtent, lessThan(80));
    });

    testWidgets('should show the verified email locked', (tester) async {
      await pumpPage(tester);

      expect(find.text('ana@example.com'), findsOneWidget);
      expect(tester.widget<TextFormField>(field(2)).enabled, isFalse);
    });

    testWidgets('should dispatch RegisterRequested with trimmed values and the emailed code', (tester) async {
      // Arrange
      await pumpPage(tester);
      await tester.enterText(field(0), ' Ana ');
      await tester.enterText(field(1), '   ');
      await tester.enterText(field(3), 'long secret 1');
      await tester.enterText(field(4), 'long secret 1');
      await acceptLegalTerms(tester);

      // Act
      await tapRegister(tester);

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single as RegisterRequested;
      expect(event.name, 'Ana');
      expect(event.surname, isNull);
      expect(event.email, 'ana@example.com');
      expect(event.password, 'long secret 1');
      expect(event.language, RecoveryPhraseLanguage.english);
      expect(event.acceptedLegalTerms, isTrue);
      expect(event.emailCode, '482913');
    });

    testWidgets('should ask for the recovery words in Spanish when the app is in Spanish', (tester) async {
      // Arrange
      await pumpPage(tester, locale: const Locale('es'));
      await fillValidForm(tester);

      // Act
      await tapRegister(tester);

      // Assert
      final event = verify(() => mockAuthBloc.add(captureAny())).captured.single as RegisterRequested;
      expect(event.language, RecoveryPhraseLanguage.spanish);
    });

    // ==================== VALIDATION ERROR TESTS ====================

    testWidgets('should show required errors and not dispatch with empty form', (tester) async {
      // Arrange
      await pumpPage(tester);

      // Act
      await tapRegister(tester);

      // Assert
      expect(find.text('Name is required'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should reject mismatching passwords', (tester) async {
      // Arrange
      await pumpPage(tester);
      await tester.enterText(field(0), 'Ana');
      await tester.enterText(field(3), 'long secret 1');
      await tester.enterText(field(4), 'long secret 2');

      // Act
      await tapRegister(tester);

      // Assert
      expect(find.text('Passwords do not match'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should not register without accepting the terms and the privacy policy', (tester) async {
      // Arrange
      await pumpPage(tester);
      await fillValidForm(tester);
      await acceptLegalTerms(tester); // untick

      // Act
      await tapRegister(tester);

      // Assert
      expect(find.text('You must accept the terms of use and the privacy policy'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    testWidgets('should reject passwords shorter than 10 characters', (tester) async {
      // Arrange: the server never sees the password, so the app is the only one that can check it
      await pumpPage(tester);
      await fillValidForm(tester);
      await tester.enterText(field(3), 'secret1');
      await tester.enterText(field(4), 'secret1');

      // Act
      await tapRegister(tester);

      // Assert
      expect(find.text('The password must have at least 10 characters.'), findsOneWidget);
      verifyNever(() => mockAuthBloc.add(any()));
    });

    // ==================== LOADING STATE TESTS ====================

    testWidgets('should show loading and disable fields while registering', (tester) async {
      // Arrange
      await pumpPage(tester, state: AuthLoading());

      // Assert
      expect(tester.widget<AppButton>(find.byType(AppButton)).loading, isTrue);
      expect(tester.widget<TextFormField>(field(0)).enabled, isFalse);
    });

    // ==================== ERROR TESTS ====================

    testWidgets('should go back to the code step when the registration rejects the code', (tester) async {
      // Arrange: the code expired while the user filled this step
      final failure = ValidationFailure(code: 'INVALID_EMAIL_CODE',
          errorResponse: ErrorResponseModel(code: 'INVALID_EMAIL_CODE', message: 'The code is not valid',
              timestamp: '2026-10-20T10:00:00'));
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthError(failure)));

      // Act
      await pumpPage(tester);
      await tester.pump();

      // Assert
      verify(() => mockEmailCubit.codeRejected()).called(1);
      expect(find.text('The code is not valid'), findsOneWidget);
    });
  });
}
