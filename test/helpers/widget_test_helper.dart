import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_theme.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Widget Test Helper Utilities
///
/// This file provides reusable helper functions to reduce code duplication
/// in widget tests across the application.
///
/// Usage Example:
/// ```dart
/// testWidgets('should render correctly', (tester) async {
///   await tester.pumpWidget(makeTestableWidget(MyWidget()));
///   expect(find.byType(MyWidget), findsOneWidget);
/// });
/// ```

/// Creates a testable widget wrapped with MaterialApp and localization support.
///
/// This helper wraps the provided [child] widget with all necessary dependencies
/// for testing, including:
/// - MaterialApp
/// - Localization delegates (Spanish and English)
/// - Theme configuration
/// - Optional navigator key for navigation testing
/// - Optional initial route
///
/// Parameters:
/// - [child]: The widget to be tested
/// - [navigatorKey]: Optional GlobalKey<NavigatorState> for testing navigation
/// - [initialRoute]: Optional initial route path
/// - [locale]: Optional locale (defaults to English)
/// - [routes]: Optional named routes map
///
/// Example:
/// ```dart
/// await tester.pumpWidget(makeTestableWidget(
///   const LoginPage(),
///   navigatorKey: navigatorKey,
/// ));
/// ```
Widget makeTestableWidget(
  Widget child, {
  GlobalKey<NavigatorState>? navigatorKey,
  String? initialRoute,
  Locale locale = const Locale('en'),
  Map<String, WidgetBuilder>? routes,
  ThemeMode themeMode = ThemeMode.light,
}) {
  return MaterialApp(
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    themeMode: themeMode,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    navigatorKey: navigatorKey,
    initialRoute: initialRoute,
    routes: routes ?? {},
    home: routes == null && initialRoute == null ? child : null,
    builder: routes != null || initialRoute != null
        ? (context, widget) => child
        : null,
  );
}

/// Creates a testable widget wrapped with a BLoC provider.
///
/// This helper is useful when testing widgets that depend on a specific BLoC.
/// It wraps the widget with both MaterialApp (via makeTestableWidget) and
/// BlocProvider.
///
/// Type Parameters:
/// - [B]: The BLoC type
///
/// Parameters:
/// - [bloc]: The BLoC instance to provide
/// - [child]: The widget to be tested
/// - [navigatorKey]: Optional GlobalKey<NavigatorState> for testing navigation
/// - [locale]: Optional locale (defaults to English)
///
/// Example:
/// ```dart
/// final mockAuthBloc = MockAuthBloc();
/// when(() => mockAuthBloc.state).thenReturn(NotAuthenticated());
///
/// await tester.pumpWidget(makeTestableWidgetWithBloc<AuthBloc>(
///   bloc: mockAuthBloc,
///   child: const LoginPage(),
/// ));
/// ```
Widget makeTestableWidgetWithBloc<B extends StateStreamableSource<Object?>>({
  required B bloc,
  required Widget child,
  GlobalKey<NavigatorState>? navigatorKey,
  Locale locale = const Locale('en'),
}) {
  return makeTestableWidget(
    // .value: the test owns the bloc (mocks need no close() stub).
    BlocProvider<B>.value(
      value: bloc,
      child: child,
    ),
    navigatorKey: navigatorKey,
    locale: locale,
  );
}

/// Creates a testable widget wrapped with multiple BLoC providers.
///
/// This helper is useful when testing widgets that depend on multiple BLoCs.
/// It wraps the widget with both MaterialApp and MultiBlocProvider.
///
/// Parameters:
/// - [providers]: List of BlocProvider instances
/// - [child]: The widget to be tested
/// - [navigatorKey]: Optional GlobalKey<NavigatorState> for testing navigation
/// - [locale]: Optional locale (defaults to English)
///
/// Example:
/// ```dart
/// await tester.pumpWidget(makeTestableWidgetWithBlocs(
///   providers: [
///     BlocProvider<AuthBloc>.value(value: mockAuthBloc),
///     BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
///   ],
///   child: const HomePage(),
/// ));
/// ```
Widget makeTestableWidgetWithBlocs({
  required List<BlocProvider> providers,
  required Widget child,
  GlobalKey<NavigatorState>? navigatorKey,
  Locale locale = const Locale('en'),
}) {
  return makeTestableWidget(
    MultiBlocProvider(
      providers: providers,
      child: child,
    ),
    navigatorKey: navigatorKey,
    locale: locale,
  );
}

/// Sets up a standard screen size for widget tests.
///
/// This helper sets the test screen to a standard Android device size
/// (1080x2400) with 1.0 pixel ratio. It also registers a tearDown callback
/// to reset the view after the test.
///
/// Call this in the beginning of your test:
/// ```dart
/// testWidgets('should render correctly', (tester) async {
///   setUpScreenSize(tester);
///   // ... rest of your test
/// });
/// ```
void setUpScreenSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() => tester.view.reset());
}

/// Sets up a custom screen size for widget tests.
///
/// Parameters:
/// - [tester]: The WidgetTester instance
/// - [width]: Screen width in logical pixels
/// - [height]: Screen height in logical pixels
/// - [devicePixelRatio]: Optional pixel ratio (defaults to 1.0)
///
/// Example:
/// ```dart
/// testWidgets('should render on tablet', (tester) async {
///   setUpCustomScreenSize(tester, 1024, 768);
///   // ... rest of your test
/// });
/// ```
void setUpCustomScreenSize(
  WidgetTester tester,
  double width,
  double height, {
  double devicePixelRatio = 1.0,
}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(() => tester.view.reset());
}