import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';
import 'package:photo_manager_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:photo_manager_app/features/gallery/domain/use_cases/get_files_use_case.dart';

class MockGalleryRepository extends Mock implements GalleryRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(FileFilter.all);
  });

  late GetFilesUseCase useCase;
  late MockGalleryRepository mockRepository;

  setUp(() {
    mockRepository = MockGalleryRepository();
    useCase = GetFilesUseCase(mockRepository);
  });

  final testDate = DateTime(2024, 1, 15);

  final testFiles = [
    GalleryFile(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
    ),
    GalleryFile(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      durationSeconds: 120,
      capturedAt: testDate,
    ),
  ];

  final testPage = GalleryPage(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
    totalFilesCount: 0,
    totalPendingCount: 0,
  );

  group('GetFilesUseCase', () {
    test('should call repository with default parameters', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      final result = await useCase.call();

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
      expect(result, testPage);
    });

    test('should call repository with custom page', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(page: 2);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 2,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should call repository with custom pageSize', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(pageSize: 100);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 100,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should call repository with images filter', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(filter: FileFilter.images);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.images,
          )).called(1);
    });

    test('should call repository with videos filter', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(filter: FileFilter.videos);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.videos,
          )).called(1);
    });

    test('should call repository with pending filter', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(filter: FileFilter.pending);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.pending,
          )).called(1);
    });

    test('should normalize negative page to 0', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(page: -5);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should normalize zero pageSize to 50', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(pageSize: 0);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should normalize negative pageSize to 50', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(pageSize: -10);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should return empty page when repository returns empty', () async {
      // Arrange
      final emptyPage = GalleryPage.empty();
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => emptyPage);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, emptyPage);
      expect(result.isEmpty, true);
    });

    test('should propagate repository errors', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsException,
      );
    });

    test('should handle large page number', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(page: 999);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 999,
            pageSize: 50,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(pageSize: 500);

      // Assert
      verify(() => mockRepository.getFiles(
            page: 0,
            pageSize: 500,
            filter: FileFilter.all,
          )).called(1);
    });

    test('should call repository with all custom parameters', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      await useCase.call(
        page: 3,
        pageSize: 100,
        filter: FileFilter.images,
      );

      // Assert
      verify(() => mockRepository.getFiles(
            page: 3,
            pageSize: 100,
            filter: FileFilter.images,
          )).called(1);
    });

    test('should return correct GalleryPage from repository', () async {
      // Arrange
      when(() => mockRepository.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            filter: any(named: 'filter'),
          )).thenAnswer((_) async => testPage);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.files, testFiles);
      expect(result.currentPage, 0);
      expect(result.pageSize, 50);
      expect(result.hasNext, true);
    });
  });
}
