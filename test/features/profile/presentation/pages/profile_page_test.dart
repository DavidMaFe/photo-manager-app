import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/services/ui_preferences_service.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/widget/error_display.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:photo_manager_app/features/profile/presentation/pages/profile_page.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_header.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/profile_stats.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/storage_bar.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/theme_mode_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockProfileBloc extends Mock implements ProfileBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeAuthEvent extends Fake implements AuthEvent {}

void main() {
  late MockProfileBloc mockProfileBloc;
  late MockAuthBloc mockAuthBloc;
  late UiPreferencesService uiPreferences;

  setUpAll(() => registerFallbackValue(FakeAuthEvent()));

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    uiPreferences = UiPreferencesService(await SharedPreferences.getInstance());
    mockProfileBloc = MockProfileBloc();
    mockAuthBloc = MockAuthBloc();
    when(() => mockProfileBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockAuthBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  Future<void> pump(WidgetTester tester, ProfileState state) async {
    setUpCustomScreenSize(tester, 390, 1600);
    when(() => mockProfileBloc.state).thenReturn(state);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<ProfileBloc>.value(value: mockProfileBloc),
        BlocProvider<AuthBloc>.value(value: mockAuthBloc),
      ],
      child: ProfilePage(uiPreferences: uiPreferences),
    ));
    await tester.pump();
  }

  /// The backup summary keeps a spinner running, so pumpAndSettle never settles.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('ProfilePage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should show the header, user row, storage and stats', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));

      // Assert
      expect(find.text('Profile'), findsOneWidget);
      expect(find.byType(ProfileHeader), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.byType(StorageBar), findsOneWidget);
      expect(find.byType(ProfileStats), findsOneWidget);
    });

    testWidgets('should list the backup/space and app rows', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));

      // Assert
      expect(find.text('BACKUP AND SPACE'), findsOneWidget);
      expect(find.text('APP'), findsOneWidget);
      expect(find.text('Backup settings'), findsOneWidget);
      expect(find.text('2 linked'), findsOneWidget);
      expect(find.text('Emptied after 30 days'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      // Security section of the end-to-end encryption
      expect(find.text('My 24 words'), findsOneWidget);
      expect(find.text('Verify my 24 words'), findsOneWidget);
      expect(find.text('I forgot my password'), findsOneWidget);
      expect(find.text('Recover locked photos'), findsOneWidget);
      // Information pages and legal texts
      expect(find.text('Information and legal'), findsOneWidget);
      expect(find.byType(ListRow), findsNWidgets(11));
    });

    testWidgets('should summarize the backup as off when it cannot be loaded', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));

      // Assert
      expect(find.text('Automatic backup off'), findsOneWidget);
    });

    // ==================== LOGOUT TESTS ====================

    testWidgets('should confirm before signing out', (tester) async {
      // Arrange (a profile without photo, so nothing keeps loading)
      await pump(tester, ProfileLoaded(TestProfiles.emptyStorageProfile));

      // Act
      await tester.tap(find.widgetWithText(AppButton, 'Sign out'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsOneWidget);
      await tester.tap(find.descendant(of: find.byType(AppDialog), matching: find.byType(AppButton)).last);
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockAuthBloc.add(any(that: isA<LogoutRequested>()))).called(1);
    });

    testWidgets('should use the danger style for sign out', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));

      // Assert
      final button = tester.widget<AppButton>(find.widgetWithText(AppButton, 'Sign out'));
      expect(button.variant, AppButtonVariant.danger);
    });

    // ==================== LOADING & ERROR TESTS ====================

    testWidgets('should show a spinner before the profile loads', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileLoading());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);
    });

    testWidgets('should show the error display when loading fails', (tester) async {
      // Arrange & Act
      await pump(tester, ProfileError(const NetworkFailure()));

      // Assert
      expect(find.byType(ErrorDisplay), findsOneWidget);
    });

    // ==================== APPEARANCE TESTS ====================

    testWidgets('should show the saved appearance', (tester) async {
      // Arrange
      await uiPreferences.setThemeMode(ThemeMode.dark);

      // Act
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));

      // Assert
      final row = tester.widget<ListRow>(find.widgetWithText(ListRow, 'Appearance'));
      expect(row.value, 'Dark');
    });

    testWidgets('should change the appearance from its sheet', (tester) async {
      // Arrange
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));
      expect(tester.widget<ListRow>(find.widgetWithText(ListRow, 'Appearance')).value, 'Automatic');

      // Act
      await tester.tap(find.text('Appearance'));
      await settle(tester);
      expect(find.byType(ThemeModeSheet), findsOneWidget);
      await tester.tap(find.text('Light'));
      await settle(tester);

      // Assert
      expect(find.byType(ThemeModeSheet), findsNothing);
      expect(uiPreferences.themeMode.value, ThemeMode.light);
      expect(tester.widget<ListRow>(find.widgetWithText(ListRow, 'Appearance')).value, 'Light');
    });

    testWidgets('should keep the appearance when the sheet is dismissed', (tester) async {
      // Arrange
      await pump(tester, ProfileLoaded(TestProfiles.johnDoeProfile));
      await tester.tap(find.text('Appearance'));
      await settle(tester);

      // Act
      await tester.tapAt(const Offset(195, 40));
      await settle(tester);

      // Assert
      expect(uiPreferences.themeMode.value, ThemeMode.system);
    });
  });
}
