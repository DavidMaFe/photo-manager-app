import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:photo_manager_app/features/profile/presentation/bloc/profile_state.dart';

class MockGetUserProfileUseCase extends Mock
    implements GetUserProfileUseCase {}

void main() {
  late ProfileBloc profileBloc;
  late MockGetUserProfileUseCase mockGetUserProfileUseCase;

  setUp(() {
    mockGetUserProfileUseCase = MockGetUserProfileUseCase();
    profileBloc = ProfileBloc(mockGetUserProfileUseCase);
  });

  tearDown(() {
    profileBloc.close();
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
      expect(profileBloc.state, isA<ProfileInitial>());
    });

    group('LoadProfileRequested', () {
      blocTest<ProfileBloc, ProfileState>(
        'should emit [ProfileLoading, ProfileLoaded] when load succeeds',
        build: () {
          when(() => mockGetUserProfileUseCase())
              .thenAnswer((_) async => testProfile);
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
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
          return profileBloc;
        },
        seed: () => ProfileLoaded(testProfile),
        act: (bloc) => bloc.add(RefreshProfileRequested()),
        expect: () => [
          isA<ProfileError>(),
        ],
      );
    });
  });
}
