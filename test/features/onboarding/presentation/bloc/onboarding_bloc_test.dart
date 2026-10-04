import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/permissions/app_permission.dart';
import 'package:photo_manager_app/core/permissions/permission_access.dart';
import 'package:photo_manager_app/core/permissions/permission_service.dart';
import 'package:photo_manager_app/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_event.dart';
import 'package:photo_manager_app/features/onboarding/presentation/bloc/onboarding_state.dart';

class MockCompleteOnboardingUseCase extends Mock implements CompleteOnboardingUseCase {}

class MockPermissionService extends Mock implements PermissionService {}

void main() {
  late MockCompleteOnboardingUseCase completeOnboarding;
  late MockPermissionService permissions;

  setUpAll(() {
    registerFallbackValue(AppPermission.photos);
  });

  setUp(() {
    completeOnboarding = MockCompleteOnboardingUseCase();
    permissions = MockPermissionService();
    when(() => completeOnboarding()).thenAnswer((_) async {});
    when(() => permissions.isGranted(any())).thenAnswer((_) async => false);
    when(() => permissions.openSettings()).thenAnswer((_) async {});
  });

  OnboardingBloc build() => OnboardingBloc(
        completeOnboardingUseCase: completeOnboarding,
        permissionService: permissions,
      );

  const granted = PermissionAccess.granted;
  const pending = PermissionAccess.pending;
  const blocked = PermissionAccess.blocked;

  group('OnboardingBloc', () {
    test('should start in the initial state', () {
      expect(build().state, const OnboardingInitial());
    });

    group('OnboardingStarted', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should show what is already granted',
        setUp: () {
          when(() => permissions.isGranted(AppPermission.background)).thenAnswer((_) async => true);
        },
        build: build,
        act: (bloc) => bloc.add(const OnboardingStarted()),
        expect: () => [const OnboardingPermissions(photos: pending, notifications: pending, background: granted)],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should treat a failing check as not granted',
        setUp: () {
          when(() => permissions.isGranted(AppPermission.photos)).thenThrow(Exception('plugin'));
        },
        build: build,
        act: (bloc) => bloc.add(const OnboardingStarted()),
        expect: () => [const OnboardingPermissions()],
      );
    });

    group('permission requests', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should mark photos as granted when the user allows them',
        setUp: () {
          when(() => permissions.request(AppPermission.photos)).thenAnswer((_) async => true);
        },
        build: build,
        seed: () => const OnboardingPermissions(),
        act: (bloc) => bloc.add(const PhotoPermissionRequested()),
        expect: () => [
          const OnboardingPermissions(requesting: AppPermission.photos),
          const OnboardingPermissions(photos: granted),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should send to settings a permission denied in the system prompt',
        setUp: () {
          when(() => permissions.request(AppPermission.notifications)).thenAnswer((_) async => false);
        },
        build: build,
        seed: () => const OnboardingPermissions(photos: granted),
        act: (bloc) => bloc.add(const NotificationPermissionRequested()),
        expect: () => [
          const OnboardingPermissions(photos: granted, requesting: AppPermission.notifications),
          const OnboardingPermissions(photos: granted, notifications: blocked),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should block the permission when the request fails',
        setUp: () {
          when(() => permissions.request(AppPermission.background)).thenThrow(Exception('plugin'));
        },
        build: build,
        seed: () => const OnboardingPermissions(),
        act: (bloc) => bloc.add(const BackgroundPermissionRequested()),
        expect: () => [
          const OnboardingPermissions(requesting: AppPermission.background),
          const OnboardingPermissions(background: blocked),
        ],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should not ask again for a granted permission',
        build: build,
        seed: () => const OnboardingPermissions(photos: granted),
        act: (bloc) => bloc.add(const PhotoPermissionRequested()),
        expect: () => <OnboardingState>[],
        verify: (_) => verifyNever(() => permissions.request(any())),
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should open the system settings',
        build: build,
        seed: () => const OnboardingPermissions(photos: blocked),
        act: (bloc) => bloc.add(const PermissionSettingsRequested()),
        expect: () => <OnboardingState>[],
        verify: (_) => verify(() => permissions.openSettings()).called(1),
      );
    });

    group('PermissionsRechecked', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should pick up a permission granted from the settings',
        setUp: () {
          when(() => permissions.isGranted(AppPermission.photos)).thenAnswer((_) async => true);
        },
        build: build,
        seed: () => const OnboardingPermissions(photos: blocked, notifications: blocked),
        act: (bloc) => bloc.add(const PermissionsRechecked()),
        expect: () => [const OnboardingPermissions(photos: granted, notifications: blocked)],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should ignore rechecks before the screen is ready',
        build: build,
        act: (bloc) => bloc.add(const PermissionsRechecked()),
        expect: () => <OnboardingState>[],
      );
    });

    group('OnboardingCompleted', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should complete with every permission granted',
        build: build,
        seed: () => const OnboardingPermissions(photos: granted, notifications: granted, background: granted),
        act: (bloc) => bloc.add(const OnboardingCompleted()),
        expect: () => [const OnboardingComplete(allPermissionsGranted: true)],
        verify: (_) => verify(() => completeOnboarding()).called(1),
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should complete later even without permissions',
        build: build,
        seed: () => const OnboardingPermissions(),
        act: (bloc) => bloc.add(const OnboardingCompleted()),
        expect: () => [const OnboardingComplete(allPermissionsGranted: false)],
      );
    });

    group('PermissionsGranted', () {
      blocTest<OnboardingBloc, OnboardingState>(
        'should complete when all permissions are granted',
        build: build,
        act: (bloc) => bloc.add(const PermissionsGranted(
          photoGranted: true,
          notificationGranted: true,
          backgroundGranted: true,
        )),
        expect: () => [const OnboardingComplete(allPermissionsGranted: true)],
      );

      blocTest<OnboardingBloc, OnboardingState>(
        'should report the denied permissions',
        build: build,
        act: (bloc) => bloc.add(const PermissionsGranted(
          photoGranted: true,
          notificationGranted: false,
          backgroundGranted: false,
        )),
        expect: () => [
          const OnboardingPermissionsPartiallyDenied(
            photoGranted: true,
            notificationGranted: false,
            backgroundGranted: false,
          ),
        ],
      );
    });
  });

  group('OnboardingPermissions', () {
    test('should recommend the first permission not granted yet', () {
      expect(const OnboardingPermissions().nextRecommended, AppPermission.photos);
      expect(const OnboardingPermissions(photos: granted).nextRecommended, AppPermission.notifications);
      expect(
        const OnboardingPermissions(photos: granted, notifications: granted, background: granted).nextRecommended,
        isNull,
      );
    });
  });
}
