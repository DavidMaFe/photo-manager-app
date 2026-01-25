import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/update_user_profile_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late UpdateUserProfileUseCase useCase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    useCase = UpdateUserProfileUseCase(mockProfileRepository);
  });

  group('UpdateUserProfileUseCase', () {
    final testProfile = UserProfile(
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

    test('should call repository updateUserProfile method with all parameters',
        () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenAnswer((_) async => testProfile);

      // Act
      await useCase(
        name: 'Jane',
        surname: 'Smith',
        profileImage: 'base64image',
      );

      // Assert
      verify(() => mockProfileRepository.updateUserProfile(
            name: 'Jane',
            surname: 'Smith',
            profileImage: 'base64image',
          )).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    });

    test('should return updated UserProfile from repository', () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenAnswer((_) async => testProfile);

      // Act
      final result = await useCase(
        name: 'Jane',
        surname: 'Smith',
      );

      // Assert
      expect(result, equals(testProfile));
      expect(result.name, 'Jane');
      expect(result.surname, 'Smith');
    });

    test('should call repository with only name when other parameters are null',
        () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenAnswer((_) async => testProfile);

      // Act
      await useCase(name: 'Jane');

      // Assert
      verify(() => mockProfileRepository.updateUserProfile(
            name: 'Jane',
            surname: null,
            profileImage: null,
          )).called(1);
    });

    test('should call repository with only surname when other parameters are null',
        () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenAnswer((_) async => testProfile);

      // Act
      await useCase(surname: 'Smith');

      // Assert
      verify(() => mockProfileRepository.updateUserProfile(
            name: null,
            surname: 'Smith',
            profileImage: null,
          )).called(1);
    });

    test(
        'should call repository with only profileImage when other parameters are null',
        () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenAnswer((_) async => testProfile);

      // Act
      await useCase(profileImage: 'base64image');

      // Assert
      verify(() => mockProfileRepository.updateUserProfile(
            name: null,
            surname: null,
            profileImage: 'base64image',
          )).called(1);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(name: 'Jane'),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Network error')),
        ),
      );

      verify(() => mockProfileRepository.updateUserProfile(
            name: 'Jane',
            surname: null,
            profileImage: null,
          )).called(1);
    });

    test('should handle unauthorized errors from repository', () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenThrow(Exception('Invalid or expired token'));

      // Act & Assert
      expect(
        () => useCase(name: 'Jane', surname: 'Smith'),
        throwsA(
          predicate((e) => e is Exception &&
              e.toString().contains('Invalid or expired token')),
        ),
      );
    });

    test('should handle validation errors from repository', () async {
      // Arrange
      when(() => mockProfileRepository.updateUserProfile(
            name: any(named: 'name'),
            surname: any(named: 'surname'),
            profileImage: any(named: 'profileImage'),
          )).thenThrow(Exception('Invalid profile data'));

      // Act & Assert
      expect(
        () => useCase(name: ''),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Invalid profile data')),
        ),
      );
    });
  });
}
