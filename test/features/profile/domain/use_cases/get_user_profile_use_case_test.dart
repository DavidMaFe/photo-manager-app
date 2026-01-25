import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:photo_manager_app/features/profile/domain/use_cases/get_user_profile_use_case.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late GetUserProfileUseCase useCase;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    useCase = GetUserProfileUseCase(mockProfileRepository);
  });

  group('GetUserProfileUseCase', () {
    final testProfile = UserProfile(
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

    test('should call repository getUserProfile method', () async {
      // Arrange
      when(() => mockProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);

      // Act
      await useCase();

      // Assert
      verify(() => mockProfileRepository.getUserProfile()).called(1);
      verifyNoMoreInteractions(mockProfileRepository);
    });

    test('should return UserProfile from repository', () async {
      // Arrange
      when(() => mockProfileRepository.getUserProfile())
          .thenAnswer((_) async => testProfile);

      // Act
      final result = await useCase();

      // Assert
      expect(result, equals(testProfile));
      expect(result.id, testProfile.id);
      expect(result.email, testProfile.email);
      expect(result.name, testProfile.name);
    });

    test('should propagate exceptions from repository', () async {
      // Arrange
      when(() => mockProfileRepository.getUserProfile())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Network error')),
        ),
      );

      verify(() => mockProfileRepository.getUserProfile()).called(1);
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(() => mockProfileRepository.getUserProfile())
          .thenThrow(Exception('Server error'));

      // Act & Assert
      expect(
        () => useCase(),
        throwsA(
          predicate((e) =>
              e is Exception && e.toString().contains('Server error')),
        ),
      );
    });
  });
}
