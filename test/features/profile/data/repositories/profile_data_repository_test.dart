import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';
import 'package:photo_manager_app/features/profile/data/models/user_profile_model.dart';
import 'package:photo_manager_app/features/profile/data/repositories/profile_data_repository.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

class FakeUserProfileModel extends Fake implements UserProfileModel {}

void main() {
  late ProfileDataRepository repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockProfileLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserProfileModel());
  });

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockLocalDataSource = MockProfileLocalDataSource();
    repository = ProfileDataRepository(
      profileRemoteDatasource: mockRemoteDataSource,
      profileLocalDataSource: mockLocalDataSource,
    );
  });

  group('ProfileDataRepository', () {
    final testProfile = UserProfileModel(
      id: '1',
      email: 'test@example.com',
      name: 'John',
      surname: 'Doe',
      hasProfileImage: true,
      storageUsedMb: 500,
      storageTotalMb: 1024,
      fileCount: 100,
      folderCount: 10,
      deviceCount: 2,
    );

    group('getUserProfile', () {
      test('should call remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => testProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.getUserProfile();

        // Assert
        verify(() => mockRemoteDataSource.getUserProfile()).called(1);
      });

      test('should cache profile after successful remote fetch', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => testProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.getUserProfile();

        // Assert
        verify(() => mockLocalDataSource.cacheProfile(testProfile)).called(1);
      });

      test('should return profile from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => testProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.getUserProfile();

        // Assert
        expect(result, testProfile);
        expect(result.id, testProfile.id);
        expect(result.email, testProfile.email);
      });

      test('should cache before returning profile', () async {
        // Arrange
        final callOrder = <String>[];
        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => testProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async {
          callOrder.add('cache');
        });

        // Act
        await repository.getUserProfile();
        callOrder.add('return');

        // Assert
        expect(callOrder, ['cache', 'return']);
      });

      test('should return cached profile when remote fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await repository.getUserProfile();

        // Assert
        expect(result, testProfile);
        verify(() => mockLocalDataSource.getCachedProfile()).called(1);
      });

      test('should not cache when remote call fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        await repository.getUserProfile();

        // Assert
        verifyNever(() => mockLocalDataSource.cacheProfile(any()));
      });

      test('should rethrow exception when remote fails and no cache exists',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => null);

        // Act & Assert
        expect(
          () => repository.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Network error')),
          ),
        );
      });

      test('should attempt cache retrieval when remote throws exception',
          () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Server error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        await repository.getUserProfile();

        // Assert
        verify(() => mockRemoteDataSource.getUserProfile()).called(1);
        verify(() => mockLocalDataSource.getCachedProfile()).called(1);
      });

      test('should handle 401 error by returning cached profile', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Invalid or expired token'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await repository.getUserProfile();

        // Assert
        expect(result, testProfile);
      });

      test('should handle timeout by returning cached profile', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Timeout'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await repository.getUserProfile();

        // Assert
        expect(result, testProfile);
      });

      test('should rethrow when both remote and cache fail', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => null);

        // Act & Assert
        await expectLater(
          repository.getUserProfile(),
          throwsException,
        );
      });
    });

    group('getCachedProfile', () {
      test('should call local data source getCachedProfile', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        await repository.getCachedProfile();

        // Assert
        verify(() => mockLocalDataSource.getCachedProfile()).called(1);
        verifyNoMoreInteractions(mockLocalDataSource);
      });

      test('should return cached profile when exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        final result = await repository.getCachedProfile();

        // Assert
        expect(result, testProfile);
        expect(result!.id, testProfile.id);
        expect(result.email, testProfile.email);
      });

      test('should return null when no cached profile exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCachedProfile();

        // Assert
        expect(result, isNull);
      });

      test('should not call remote data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        await repository.getCachedProfile();

        // Assert
        verifyNever(() => mockRemoteDataSource.getUserProfile());
      });
    });

    group('cache-first strategy', () {
      test('should prioritize remote over cache', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => testProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.getUserProfile();

        // Assert - remote should be called, not cache retrieval
        verify(() => mockRemoteDataSource.getUserProfile()).called(1);
        verifyNever(() => mockLocalDataSource.getCachedProfile());
      });

      test('should fallback to cache only on remote failure', () async {
        // Arrange
        when(() => mockRemoteDataSource.getUserProfile())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.getCachedProfile())
            .thenAnswer((_) async => testProfile);

        // Act
        await repository.getUserProfile();

        // Assert
        verify(() => mockRemoteDataSource.getUserProfile()).called(1);
        verify(() => mockLocalDataSource.getCachedProfile()).called(1);
      });

      test('should update cache with fresh remote data', () async {
        // Arrange
        final freshProfile = UserProfileModel(
          id: '1',
          email: 'updated@example.com',
          name: 'Updated',
          hasProfileImage: false,
          storageUsedMb: 600,
          storageTotalMb: 1024,
          fileCount: 150,
          folderCount: 15,
          deviceCount: 3,
        );

        when(() => mockRemoteDataSource.getUserProfile())
            .thenAnswer((_) async => freshProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.getUserProfile();

        // Assert
        verify(() => mockLocalDataSource.cacheProfile(freshProfile)).called(1);
      });
    });

    group('updateUserProfile', () {
      final updatedProfile = UserProfileModel(
        id: '1',
        email: 'test@example.com',
        name: 'Jane',
        surname: 'Smith',
        hasProfileImage: true,
        storageUsedMb: 500,
        storageTotalMb: 1024,
        fileCount: 100,
        folderCount: 10,
        deviceCount: 2,
      );

      test('should call remote data source with all parameters', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenAnswer((_) async => updatedProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateUserProfile(
          name: 'Jane',
          surname: 'Smith',
          profileImage: 'base64image',
        );

        // Assert
        verify(() => mockRemoteDataSource.updateUserProfile(
              name: 'Jane',
              surname: 'Smith',
              profileImage: 'base64image',
            )).called(1);
      });

      test('should cache updated profile after successful update', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenAnswer((_) async => updatedProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateUserProfile(name: 'Jane');

        // Assert
        verify(() => mockLocalDataSource.cacheProfile(updatedProfile)).called(1);
      });

      test('should return updated profile from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenAnswer((_) async => updatedProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        final result = await repository.updateUserProfile(
          name: 'Jane',
          surname: 'Smith',
        );

        // Assert
        expect(result, updatedProfile);
        expect(result.name, 'Jane');
        expect(result.surname, 'Smith');
      });

      test('should update cache before returning profile', () async {
        // Arrange
        final callOrder = <String>[];
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenAnswer((_) async => updatedProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async {
          callOrder.add('cache');
        });

        // Act
        await repository.updateUserProfile(name: 'Jane');
        callOrder.add('return');

        // Assert
        expect(callOrder, ['cache', 'return']);
      });

      test('should propagate exceptions from remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => repository.updateUserProfile(name: 'Jane'),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Network error')),
          ),
        );
      });

      test('should not cache when update fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenThrow(Exception('Update failed'));

        // Act & Assert
        try {
          await repository.updateUserProfile(name: 'Jane');
        } catch (e) {
          // Expected exception
        }

        // Assert
        verifyNever(() => mockLocalDataSource.cacheProfile(any()));
      });

      test('should handle unauthorized error during update', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenThrow(Exception('Invalid or expired token'));

        // Act & Assert
        expect(
          () => repository.updateUserProfile(name: 'Jane'),
          throwsA(
            predicate((e) => e is Exception &&
                e.toString().contains('Invalid or expired token')),
          ),
        );
      });

      test('should handle validation error during update', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenThrow(Exception('Invalid profile data'));

        // Act & Assert
        expect(
          () => repository.updateUserProfile(name: ''),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Invalid profile data')),
          ),
        );
      });

      test('should pass through null parameters correctly', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateUserProfile(
              name: any(named: 'name'),
              surname: any(named: 'surname'),
              profileImage: any(named: 'profileImage'),
            )).thenAnswer((_) async => updatedProfile);
        when(() => mockLocalDataSource.cacheProfile(any()))
            .thenAnswer((_) async => {});

        // Act
        await repository.updateUserProfile(name: 'Jane');

        // Assert
        verify(() => mockRemoteDataSource.updateUserProfile(
              name: 'Jane',
              surname: null,
              profileImage: null,
            )).called(1);
      });
    });

  });
}
