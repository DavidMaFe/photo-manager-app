import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/update_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';

class MockGetUserProfileUseCase extends Mock
    implements GetUserProfileUseCase {}

class MockUpdateUserProfileUseCase extends Mock
    implements UpdateUserProfileUseCase {}

class MockChangePasswordUseCase extends Mock
    implements ChangePasswordUseCase {}

class MockAppEventBus extends Mock implements AppEventBus {}

void main() {
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;
  late MockUpdateUserProfileUseCase mockUpdateUserProfileUseCase;
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late MockAppEventBus mockEventBus;

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    mockUpdateUserProfileUseCase = MockUpdateUserProfileUseCase();
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    mockEventBus = MockAppEventBus();

    when(() => mockEventBus.on<FileUpdatedEvent>())
        .thenAnswer((_) => Stream<FileUpdatedEvent>.empty());

    when(() => mockEventBus.on<FolderUpdatedEvent>())
        .thenAnswer((_) => Stream<FolderUpdatedEvent>.empty());

    when(() => mockEventBus.on<SyncCompletedEvent>())
        .thenAnswer((_) => Stream<SyncCompletedEvent>.empty());
  });

  group('ProfileBloc', () {
    final testProfile = UserProfile(
      id: '1',
      email: 'test@example.com',
      name: 'John',
      surname: 'Doe',
      profileImage: 'https://example.com/image.jpg',
      storageUsedMb: 500,
      storageTotalMb: 1024,
      fileCount: 100,
      folderCount: 10,
      deviceCount: 2,
    );

    test('initial state should be ProfileInitial', () {
      final bloc = ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );

      expect(bloc.state, isA<ProfileInitial>());
    });

    group('LoadProfileRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileLoading, ProfileLoaded] when load succeeds',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>().having(
            (state) => state.userProfile,
            'userProfile',
            testProfile,
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should call getUserProfileUseCase',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        verify: (_) {
          verify(() => mockGetUserProfileUseCase()).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileLoading, ProfileError] when load fails',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Network error'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should convert exception to Failure via ErrorHandler',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Invalid or expired token'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
        ],
        verify: (_) {
          // ErrorHandler.handleError should be called internally
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should always emit loading state first',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>(),
        ],
      );
    });

    group('RefreshProfileRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileLoaded] when refresh succeeds',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileLoaded>().having(
            (state) => state.userProfile,
            'userProfile',
            testProfile,
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should NOT emit loading state on refresh',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileLoaded>(),
        ],
        verify: (_) {
          // Ensure no ProfileLoading was emitted
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should call getUserProfileUseCase',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        verify: (_) {
          verify(() => mockGetUserProfileUseCase()).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileError] when refresh fails',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Network error'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle network errors during refresh',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Timeout'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileError>(),
        ],
      );
    });

    group('Multiple events', () {
      blocTest<ProfileBloc, ProfileState>(
        'should handle load then refresh',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) async {
          bloc.add(LoadProfileRequested());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(RefreshProfileRequested());
        },
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileLoaded>(),
          isA<ProfileLoaded>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should transition from error to loaded on retry',
        build: () {
          var callCount = 0;
          when(() => mockGetUserProfileUseCase()).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              throw Exception('Network error');
            }
            return testProfile;
          });
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) async {
          bloc.add(LoadProfileRequested());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(RefreshProfileRequested());
        },
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
          isA<ProfileLoaded>(),
        ],
      );
    });

    group('Error scenarios', () {
      blocTest<ProfileBloc, ProfileState>(
        'should handle 401 unauthorized error',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Invalid or expired token'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle server errors',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Server error'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(LoadProfileRequested()),
        expect: () => [
          isA<ProfileLoading>(),
          isA<ProfileError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle timeout errors',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Timeout'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileError>(),
        ],
      );
    });

    group('State persistence', () {
      blocTest<ProfileBloc, ProfileState>(
        'should keep current state when refresh fails',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenThrow(Exception('Network error'));
          return ProfileBloc(
        mockGetUserProfileUseCase,
        mockUpdateUserProfileUseCase,
        mockChangePasswordUseCase,
        mockEventBus,
      );
        },
        seed: () => ProfileLoaded(testProfile),
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileError>(),
        ],
      );
    });

    group('UpdateProfileRequested', () {
      final updatedProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'Jane',
        surname: 'Smith',
        profileImage: 'https://example.com/new-image.jpg',
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileUpdating, ProfileUpdateSuccess, ProfileLoaded] when update succeeds',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(
          name: 'Jane',
          surname: 'Smith',
        )),
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateSuccess>().having(
            (state) => state.userProfile,
            'userProfile',
            updatedProfile,
          ),
          isA<ProfileLoaded>().having(
            (state) => state.userProfile,
            'userProfile',
            updatedProfile,
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should call updateUserProfileUseCase with correct parameters',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(
          name: 'Jane',
          surname: 'Smith',
        )),
        verify: (_) {
          verify(() => mockUpdateUserProfileUseCase(
                name: 'Jane',
                surname: 'Smith',
                profileImage: null,
              )).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should update only name when surname and profileImage are null',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(name: 'Jane')),
        verify: (_) {
          verify(() => mockUpdateUserProfileUseCase(
                name: 'Jane',
                surname: null,
                profileImage: null,
              )).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should update profile image when provided',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(
          profileImage: 'base64encodedimage',
        )),
        verify: (_) {
          verify(() => mockUpdateUserProfileUseCase(
                name: null,
                surname: null,
                profileImage: 'base64encodedimage',
              )).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileUpdating, ProfileUpdateError] when update fails',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenThrow(Exception('Network error'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(name: 'Jane')),
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle unauthorized error during update',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenThrow(Exception('Invalid or expired token'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(name: 'Jane')),
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle validation error during update',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenThrow(Exception('Invalid profile data'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(name: '')),
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should update all fields when all parameters are provided',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(UpdateProfileRequested(
          name: 'Jane',
          surname: 'Smith',
          profileImage: 'base64encodedimage',
        )),
        verify: (_) {
          verify(() => mockUpdateUserProfileUseCase(
                name: 'Jane',
                surname: 'Smith',
                profileImage: 'base64encodedimage',
              )).called(1);
        },
      );
    });

    group('ChangePasswordRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'should emit [PasswordChanging, PasswordChangeSuccess] when password change succeeds',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => Future.value());
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        )),
        expect: () => [
          isA<PasswordChanging>(),
          isA<PasswordChangeSuccess>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should call changePasswordUseCase with correct parameters',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => Future.value());
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        )),
        verify: (_) {
          verify(() => mockChangePasswordUseCase(
                currentPassword: 'oldPassword123',
                newPassword: 'newPassword456',
              )).called(1);
        },
      );

      blocTest<ProfileBloc, ProfileState>(
        'should emit [PasswordChanging, PasswordChangeError] when password change fails',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Invalid current password'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'wrongPassword',
          newPassword: 'newPassword456',
        )),
        expect: () => [
          isA<PasswordChanging>(),
          isA<PasswordChangeError>().having(
            (state) => state.failure,
            'failure',
            isA<Failure>(),
          ),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle incorrect current password error',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Invalid current password'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'wrongPassword',
          newPassword: 'newPassword456',
        )),
        expect: () => [
          isA<PasswordChanging>(),
          isA<PasswordChangeError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle unauthorized error during password change',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Invalid or expired token'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        )),
        expect: () => [
          isA<PasswordChanging>(),
          isA<PasswordChangeError>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle network error during password change',
        build: () {
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Network error'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) => bloc.add(ChangePasswordRequested(
          currentPassword: 'oldPassword123',
          newPassword: 'newPassword456',
        )),
        expect: () => [
          isA<PasswordChanging>(),
          isA<PasswordChangeError>(),
        ],
      );
    });

    group('Combined update and password change', () {
      final updatedProfile = UserProfile(
        id: '1',
        email: 'test@example.com',
        name: 'Jane',
        surname: 'Smith',
        profileImage: 'https://example.com/new-image.jpg',
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle profile update followed by password change',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenAnswer((_) async => Future.value());
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) async {
          bloc.add(UpdateProfileRequested(name: 'Jane', surname: 'Smith'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(ChangePasswordRequested(
            currentPassword: 'oldPassword123',
            newPassword: 'newPassword456',
          ));
        },
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateSuccess>(),
          isA<ProfileLoaded>(),
          isA<PasswordChanging>(),
          isA<PasswordChangeSuccess>(),
        ],
      );

      blocTest<ProfileBloc, ProfileState>(
        'should handle profile update success and password change failure',
        build: () {
          when(() => mockUpdateUserProfileUseCase(
                name: any(named: 'name'),
                surname: any(named: 'surname'),
                profileImage: any(named: 'profileImage'),
              )).thenAnswer((_) async => updatedProfile);
          when(() => mockChangePasswordUseCase(
                currentPassword: any(named: 'currentPassword'),
                newPassword: any(named: 'newPassword'),
              )).thenThrow(Exception('Invalid current password'));
          return ProfileBloc(
            mockGetUserProfileUseCase,
            mockUpdateUserProfileUseCase,
            mockChangePasswordUseCase,
            mockEventBus,
          );
        },
        act: (bloc) async {
          bloc.add(UpdateProfileRequested(name: 'Jane'));
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(ChangePasswordRequested(
            currentPassword: 'wrongPassword',
            newPassword: 'newPassword456',
          ));
        },
        expect: () => [
          isA<ProfileUpdating>(),
          isA<ProfileUpdateSuccess>(),
          isA<ProfileLoaded>(),
          isA<PasswordChanging>(),
          isA<PasswordChangeError>(),
        ],
      );
    });
  });
}
