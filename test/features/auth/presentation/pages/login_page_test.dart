import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/legal/presentation/widgets/legal_info_link.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';

import '../../../../helpers/widget_test_helper.dart';

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockAuthBloc mockAuthBloc;

  setUpAll(() {
    registerFallbackValue(FakeAuthEvent());
  });

  setUp(() {
    mockAuthBloc = MockAuthBloc();
    when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
    when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(NotAuthenticated()));
    when(() => mockAuthBloc.close()).thenAnswer((_) async => {});
  });

  Widget makeLoginPage() {
    return makeTestableWidgetWithBloc<AuthBloc>(bloc: mockAuthBloc, child: const LoginPage());
  }

  group('LoginPage', () {
    testWidgets('should link to the information and the legal texts without a session', (tester) async {
      setUpScreenSize(tester);

      await tester.pumpWidget(makeLoginPage());

      expect(find.byType(LegalInfoLink), findsOneWidget);
      expect(find.text('How it works, terms and privacy'), findsOneWidget);
    });

    testWidgets('should validate empty email', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      final loginButton = find.byType(AppButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter an email address'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('The email format is invalid.'), findsOneWidget);
    });

    testWidgets('should validate empty password', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should dispatch LoginRequested event when form is valid', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(AppButton));
      await tester.pump();

      // Assert
      verify(() => mockAuthBloc.add(any())).called(1);
    });

    testWidgets('should show loading indicator when AuthLoading state', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable input fields when loading', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      final emailField = tester.widget<TextFormField>(find.byType(TextFormField).first);
      final passwordField = tester.widget<TextFormField>(find.byType(TextFormField).last);

      expect(emailField.enabled, false);
      expect(passwordField.enabled, false);
    });

    testWidgets('should disable login button when loading', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeLoginPage());

      // Assert
      final loginButton = tester.widget<AppButton>(find.byType(AppButton));
      expect(loginButton.loading, isTrue);
    });

    testWidgets('should show error snackbar when AuthError state', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      const failure = NetworkFailure();
      when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
      when(() => mockAuthBloc.stream).thenAnswer(
        (_) => Stream.value(AuthError(failure)),
      );

      // Act
      await tester.pumpWidget(makeLoginPage());
      await tester.pump(); // Trigger the stream
      await tester.pump(); // Build the snackbar

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Assert initial state - visibility_off icon should be visible
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);

      // Act - Tap the visibility toggle icon
      await tester.tap(find.byIcon(Symbols.visibility_off_rounded));
      await tester.pump();

      // Assert - visibility icon should now be visible
      expect(find.byIcon(Symbols.visibility_rounded), findsOneWidget);

      // Act - Tap again to hide
      await tester.tap(find.byIcon(Symbols.visibility_rounded));
      await tester.pump();

      // Assert - back to visibility_off icon
      expect(find.byIcon(Symbols.visibility_off_rounded), findsOneWidget);
    });

    testWidgets('should trim email before dispatching event', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeLoginPage());

      // Act
      await tester.enterText(find.byType(TextFormField).first, '  test@example.com  ');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(AppButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthBloc.add(any())).called(1);
    });
  });
}
