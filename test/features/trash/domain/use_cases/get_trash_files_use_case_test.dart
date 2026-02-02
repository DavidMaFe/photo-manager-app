import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';
import 'package:photo_manager_app/features/trash/domain/repositories/trash_repository.dart';
import 'package:photo_manager_app/features/trash/domain/use_cases/get_trash_files_use_case.dart';

class MockTrashRepository extends Mock implements TrashRepository {}

void main() {
  late GetTrashFilesUseCase useCase;
  late MockTrashRepository mockRepository;

  setUp(() {
    mockRepository = MockTrashRepository();
    useCase = GetTrashFilesUseCase(mockRepository);
  });

  final now = DateTime.now();
  final testDate = DateTime(2024, 1, 15);
  final deletedAt = now.subtract(const Duration(days: 5));

  final testFiles = [
    TrashFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
      deletedAt: deletedAt,
      sizeBytes: 1024,
    ),
    TrashFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.managed,
      capturedAt: testDate,
      deletedAt: deletedAt,
      sizeBytes: 2048,
      durationSeconds: 120,
    ),
  ];

  final testPage = TrashPage(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
  );

  group('GetTrashFilesUseCase', () {
    group('successful calls', () {
      test('should call repository with provided parameters', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        final result = await useCase.call(page: 0, pageSize: 50);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 0,
              pageSize: 50,
            )).called(1);
        expect(result, testPage);
      });

      test('should call repository with custom page', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 2, pageSize: 50);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 2,
              pageSize: 50,
            )).called(1);
      });

      test('should call repository with custom pageSize', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 0, pageSize: 100);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 0,
              pageSize: 100,
            )).called(1);
      });

      test('should return empty page when repository returns empty', () async {
        // Arrange
        final emptyPage = TrashPage.empty();
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => emptyPage);

        // Act
        final result = await useCase.call(page: 0, pageSize: 50);

        // Assert
        expect(result, emptyPage);
        expect(result.isEmpty, true);
      });

      test('should return correct TrashPage from repository', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        final result = await useCase.call(page: 0, pageSize: 50);

        // Assert
        expect(result.files, testFiles);
        expect(result.currentPage, 0);
        expect(result.pageSize, 50);
        expect(result.hasNext, true);
      });
    });

    group('validation errors', () {
      test('should throw ArgumentError when page is negative', () async {
        // Act & Assert
        expect(
          () => useCase.call(page: -1, pageSize: 50),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Page number must be non-negative',
          )),
        );
      });

      test('should throw ArgumentError when pageSize is zero', () async {
        // Act & Assert
        expect(
          () => useCase.call(page: 0, pageSize: 0),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Page size must be between 1 and 100',
          )),
        );
      });

      test('should throw ArgumentError when pageSize is negative', () async {
        // Act & Assert
        expect(
          () => useCase.call(page: 0, pageSize: -10),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Page size must be between 1 and 100',
          )),
        );
      });

      test('should throw ArgumentError when pageSize exceeds 100', () async {
        // Act & Assert
        expect(
          () => useCase.call(page: 0, pageSize: 101),
          throwsA(isA<ArgumentError>().having(
            (e) => e.message,
            'message',
            'Page size must be between 1 and 100',
          )),
        );
      });
    });

    group('edge cases', () {
      test('should accept page 0', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 0, pageSize: 50);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 0,
              pageSize: 50,
            )).called(1);
      });

      test('should accept pageSize 1', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 0, pageSize: 1);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 0,
              pageSize: 1,
            )).called(1);
      });

      test('should accept pageSize 100', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 0, pageSize: 100);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 0,
              pageSize: 100,
            )).called(1);
      });

      test('should handle large page number', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenAnswer((_) async => testPage);

        // Act
        await useCase.call(page: 999, pageSize: 50);

        // Assert
        verify(() => mockRepository.getTrashFiles(
              page: 999,
              pageSize: 50,
            )).called(1);
      });

      test('should propagate repository errors', () async {
        // Arrange
        when(() => mockRepository.getTrashFiles(
              page: any(named: 'page'),
              pageSize: any(named: 'pageSize'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert
        expect(
          () => useCase.call(page: 0, pageSize: 50),
          throwsException,
        );
      });
    });
  });
}
