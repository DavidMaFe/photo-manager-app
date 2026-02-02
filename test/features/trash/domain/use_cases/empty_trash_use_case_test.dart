import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/empty_trash_use_case.dart';

class MockTrashRepository extends Mock implements TrashRepository {}

void main() {
  late EmptyTrashUseCase useCase;
  late MockTrashRepository mockRepository;

  setUp(() {
    mockRepository = MockTrashRepository();
    useCase = EmptyTrashUseCase(mockRepository);
  });

  group('EmptyTrashUseCase', () {
    group('successful calls', () {
      test('should call repository emptyTrash', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenAnswer((_) async => {});

        // Act
        await useCase.call();

        // Assert
        verify(() => mockRepository.emptyTrash()).called(1);
      });

      test('should complete successfully when repository completes', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenAnswer((_) async => {});

        // Act & Assert
        await expectLater(
          useCase.call(),
          completes,
        );
      });

      test('should not call repository multiple times for single call', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenAnswer((_) async => {});

        // Act
        await useCase.call();

        // Assert
        verify(() => mockRepository.emptyTrash()).called(1);
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('error handling', () {
      test('should propagate repository network errors', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsException,
        );
      });

      test('should propagate repository server errors', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenThrow(Exception('Server error'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsException,
        );
      });

      test('should propagate repository timeout errors', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenThrow(Exception('Timeout'));

        // Act & Assert
        expect(
          () => useCase.call(),
          throwsException,
        );
      });
    });

    group('edge cases', () {
      test('should handle repeated calls', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenAnswer((_) async => {});

        // Act
        await useCase.call();
        await useCase.call();
        await useCase.call();

        // Assert
        verify(() => mockRepository.emptyTrash()).called(3);
      });

      test('should handle delayed repository response', () async {
        // Arrange
        when(() => mockRepository.emptyTrash())
            .thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        // Act & Assert
        await expectLater(
          useCase.call(),
          completes,
        );
      });
    });
  });
}
