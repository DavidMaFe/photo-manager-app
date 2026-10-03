import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:photo_manager_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:photo_manager_app/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:photo_manager_app/features/onboarding/presentation/widgets/permission_card.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

class MockOnboardingBloc extends Mock implements OnboardingBloc {}

class MockAuthBloc extends Mock implements AuthBloc {}

class FakeOnboardingEvent extends Fake implements OnboardingEvent {}

void main() {
  late MockOnboardingBloc onboardingBloc;
  late MockAuthBloc authBloc;
  late int finished;

  const granted = PermissionAccess.granted;
  const blocked = PermissionAccess.blocked;

  setUpAll(() {
    registerFallbackValue(FakeOnboardingEvent());
  });

  setUp(() {
    finished = 0;
    onboardingBloc = MockOnboardingBloc();
    when(() => onboardingBloc.stream).thenAnswer((_) => const Stream.empty());
    authBloc = MockAuthBloc();
    when(() => authBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => authBloc.state).thenReturn(AuthSuccessful(TestUsers.johnDoe));
  });

  Future<void> pump(WidgetTester tester, OnboardingState state, {Stream<OnboardingState>? stream}) async {
    setUpCustomScreenSize(tester, 390, 1200);
    when(() => onboardingBloc.state).thenReturn(state);
    if (stream != null) when(() => onboardingBloc.stream).thenAnswer((_) => stream);
    await tester.pumpWidget(makeTestableWidgetWithBlocs(
      providers: [
        BlocProvider<OnboardingBloc>.value(value: onboardingBloc),
        BlocProvider<AuthBloc>.value(value: authBloc),
      ],
      child: OnboardingPage(onFinished: (_) => finished++),
    ));
    await tester.pump();
  }

  PermissionCard cardFor(WidgetTester tester, String title) {
    return tester.widget<PermissionCard>(find.ancestor(of: find.text(title), matching: find.byType(PermissionCard)));
  }

  group('OnboardingPage', () {
    // ==================== HAPPY PATH TESTS ====================

    testWidgets('should check the permissions when it opens', (tester) async {
      // Arrange & Act
      await pump(tester, const OnboardingInitial());

      // Assert
      verify(() => onboardingBloc.add(const OnboardingStarted())).called(1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should welcome the user and list the three permissions', (tester) async {
      // Arrange & Act
      await pump(tester, const OnboardingPermissions());

      // Assert
      expect(find.text('Welcome, John'), findsOneWidget);
      expect(find.text("Three permissions and we're ready"), findsOneWidget);
      expect(find.byType(PermissionCard), findsNWidgets(3));
      expect(find.text('Photos and videos'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Background'), findsOneWidget);
      expect(find.textContaining('Your photos are private'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('Do it later'), findsOneWidget);
    });

    testWidgets('should not invent a name when the user is unknown', (tester) async {
      // Arrange
      when(() => authBloc.state).thenReturn(AuthInitial());

      // Act
      await pump(tester, const OnboardingPermissions());

      // Assert
      expect(find.text('Welcome'), findsOneWidget);
    });

    testWidgets('should recommend the next permission to grant', (tester) async {
      // Arrange & Act
      await pump(tester, const OnboardingPermissions(photos: granted));

      // Assert
      expect(cardFor(tester, 'Photos and videos').access, granted);
      expect(cardFor(tester, 'Notifications').recommended, isTrue);
      expect(cardFor(tester, 'Background').recommended, isFalse);
    });

    testWidgets('should ask for each permission separately', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions());

      // Act
      await tester.tap(find.text('Allow').at(0));
      await tester.tap(find.text('Allow').at(1));
      await tester.tap(find.text('Allow').at(2));

      // Assert
      verify(() => onboardingBloc.add(const PhotoPermissionRequested())).called(1);
      verify(() => onboardingBloc.add(const NotificationPermissionRequested())).called(1);
      verify(() => onboardingBloc.add(const BackgroundPermissionRequested())).called(1);
    });

    testWidgets('should show a spinner on the permission being requested', (tester) async {
      // Arrange & Act
      await pump(tester, const OnboardingPermissions(requesting: AppPermission.photos));

      // Assert
      expect(cardFor(tester, 'Photos and videos').loading, isTrue);
    });

    testWidgets('should open the settings for a blocked permission', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions(photos: granted, notifications: blocked));

      // Act
      await tester.tap(find.text('Settings'));

      // Assert
      verify(() => onboardingBloc.add(const PermissionSettingsRequested())).called(1);
    });

    // ==================== CONTINUE TESTS ====================

    testWidgets('should continue straight away with photo access', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions(photos: granted));

      // Act
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppDialog), findsNothing);
      verify(() => onboardingBloc.add(const OnboardingCompleted())).called(1);
    });

    testWidgets('should explain the limitations before continuing without photos', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions(notifications: granted));

      // Act
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppDialog), findsOneWidget);
      expect(find.textContaining('sync photos or videos', findRichText: true), findsOneWidget);
      verifyNever(() => onboardingBloc.add(const OnboardingCompleted()));

      // Act
      await tester.tap(find.text('Continue anyway'));
      await tester.pumpAndSettle();

      // Assert
      verify(() => onboardingBloc.add(const OnboardingCompleted())).called(1);
    });

    testWidgets('should stay on the screen to review the permissions', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions());
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      // Act
      await tester.tap(find.text('Review permissions'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AppDialog), findsNothing);
      verifyNever(() => onboardingBloc.add(const OnboardingCompleted()));
    });

    testWidgets('should let the user do it later', (tester) async {
      // Arrange
      await pump(tester, const OnboardingPermissions());

      // Act
      await tester.tap(find.text('Do it later'));

      // Assert
      verify(() => onboardingBloc.add(const OnboardingCompleted())).called(1);
    });

    testWidgets('should leave the onboarding once it is complete', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        const OnboardingPermissions(),
        stream: Stream.value(const OnboardingComplete(allPermissionsGranted: false)).asBroadcastStream(),
      );
      await tester.pump();

      // Assert
      expect(finished, 1);
    });
  });
}
