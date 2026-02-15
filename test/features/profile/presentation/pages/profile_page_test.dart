import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/profile_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}
class MockAuthBloc extends Mock implements AuthBloc {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockAuthBloc mockAuthBloc;

  final testProfile = UserProfile(
    id: '1',
    email: 'test@example.com',
    name: 'John',
    surname: 'Doe',
    // No profileImage to avoid network image loading in tests
    hasProfileImage: false,
    storageUsedMb: 500,
    storageTotalMb: 1024,
    fileCount: 100,
    folderCount: 10,
    deviceCount: 2,
  );

  setUp(() {
    mockProfileBloc = MockProfileBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
    when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.value(ProfileInitial()));
    when(() => mockProfileBloc.close()).thenAnswer((_) async => {});
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.close()).thenAnswer((_) async => {});
  });

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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ProfileBloc>(create: (_) => mockProfileBloc),
          BlocProvider<AuthBloc>(create: (_) => mockAuthBloc),
        ],
        child: child,
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('should display loading indicator when ProfileLoading state', (tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(ProfileLoading());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.value(ProfileLoading()));

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display profile content when ProfileLoaded state', (tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(testProfile));
      when(() => mockProfileBloc.stream).thenAnswer(
        (_) => Stream.value(ProfileLoaded(testProfile)),
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));

      // Assert
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('test@example.com'), findsOneWidget);
    });

    testWidgets('should display RefreshIndicator when ProfileLoaded', (tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(ProfileLoaded(testProfile));
      when(() => mockProfileBloc.stream).thenAnswer(
        (_) => Stream.value(ProfileLoaded(testProfile)),
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('should show error snackbar when ProfileError state', (tester) async {
      // Arrange
      const failure = NetworkFailure();
      when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer(
        (_) => Stream.value(ProfileError(failure)),
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));
      await tester.pump(); // Trigger the stream
      await tester.pump(); // Build the snackbar

      // Assert
      expect(find.byType(SnackBar), findsOneWidget);
    });

    testWidgets('should return empty widget on error state', (tester) async {
      // Arrange
      const failure = NetworkFailure();
      when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer(
        (_) => Stream.value(ProfileError(failure)),
      );

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));
      await tester.pump();
      await tester.pump();

      // Assert - Verify loading indicator is not shown
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(RefreshIndicator), findsNothing);
    });

    testWidgets('should return empty widget when state is ProfileInitial', (tester) async {
      // Arrange
      when(() => mockProfileBloc.state).thenReturn(ProfileInitial());
      when(() => mockProfileBloc.stream).thenAnswer((_) => Stream.value(ProfileInitial()));

      // Act
      await tester.pumpWidget(makeTestableWidget(const ProfilePage()));

      // Assert
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}
