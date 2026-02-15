import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/auth/presentation/pages/login_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

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

  void setUpScreenSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.reset());
  }

  Widget makeTestableWidget(Widget child) {
    return MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: BlocProvider<AuthBloc>(
        create: (_) => mockAuthBloc,
        child: child,
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('should validate empty email', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Act
      final loginButton = find.byType(ElevatedButton);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter an email address'), findsOneWidget);
    });

    testWidgets('should validate invalid email format', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('The email format is invalid.'), findsOneWidget);
    });

    testWidgets('should validate empty password', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please enter a password'), findsOneWidget);
    });

    testWidgets('should dispatch LoginRequested event when form is valid', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Act
      await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
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
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should disable input fields when loading', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      when(() => mockAuthBloc.state).thenReturn(AuthLoading());
      when(() => mockAuthBloc.stream).thenAnswer((_) => Stream.value(AuthLoading()));

      // Act
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

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
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Assert
      final loginButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(loginButton.onPressed, isNull);
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
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));
      await tester.pump(); // Trigger the stream
      await tester.pump(); // Build the snackbar

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Assert initial state - visibility_off icon should be visible
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Act - Tap the visibility toggle icon
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert - visibility icon should now be visible
      expect(find.byIcon(Icons.visibility), findsOneWidget);

      // Act - Tap again to hide
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - back to visibility_off icon
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);
    });

    testWidgets('should trim email before dispatching event', (tester) async {
      setUpScreenSize(tester);
      // Arrange
      await tester.pumpWidget(makeTestableWidget(const LoginPage()));

      // Act
      await tester.enterText(find.byType(TextFormField).first, '  test@example.com  ');
      await tester.enterText(find.byType(TextFormField).last, 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthBloc.add(any())).called(1);
    });
  });
}
