import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_file_model.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_page_model.dart';
import 'package:photo_manager_app/features/gallery/data/repositories/gallery_repository_impl.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_page.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';

class MockGalleryRemoteDataSource extends Mock
    implements GalleryRemoteDataSource {}

void main() {
  late GalleryRepositoryImpl repository;
  late MockGalleryRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockGalleryRemoteDataSource();
    repository = GalleryRepositoryImpl(mockRemoteDataSource);
  });

  final testDate = DateTime(2024, 1, 15);

  final testFiles = [
    GalleryFileModel(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testDate,
    ),
    GalleryFileModel(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      durationSeconds: 120,
      capturedAt: testDate,
    ),
  ];

  final testPageModel = GalleryPageModel(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
  );

  group('GalleryRepositoryImpl - getFiles', () {
    test('should call remote data source with correct parameters', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 50,
            type: null,
            status: null,
          )).called(1);
    });

    test('should return GalleryPage entity from data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      final result = await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      expect(result, isA<GalleryPage>());
      expect(result.files.length, 2);
      expect(result.currentPage, 0);
      expect(result.pageSize, 50);
      expect(result.hasNext, true);
    });

    test('should convert FileFilter.all to null type and null status', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 50,
            type: null,
            status: null,
          )).called(1);
    });

    test('should convert FileFilter.images to IMAGE type', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.images,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 50,
            type: 'IMAGE',
            status: null,
          )).called(1);
    });

    test('should convert FileFilter.videos to VIDEO type', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.videos,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 50,
            type: 'VIDEO',
            status: null,
          )).called(1);
    });

    test('should convert FileFilter.pending to PENDING status', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.pending,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 50,
            type: null,
            status: 'PENDING',
          )).called(1);
    });

    test('should handle different page numbers', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 3,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 3,
            pageSize: 50,
            type: null,
            status: null,
          )).called(1);
    });

    test('should handle different page sizes', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 100,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 100,
            type: null,
            status: null,
          )).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getFiles(
          page: 0,
          pageSize: 50,
          filter: FileFilter.all,
        ),
        throwsException,
      );
    });

    test('should return empty page when data source returns empty', () async {
      // Arrange
      const emptyPageModel = GalleryPageModel(
        files: [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => emptyPageModel);

      // Act
      final result = await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      expect(result.files, isEmpty);
      expect(result.hasNext, false);
    });

    test('should call data source only once per request', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).called(1);
    });

    test('should handle page with single file', () async {
      // Arrange
      final singleFilePageModel = GalleryPageModel(
        files: [testFiles.first],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => singleFilePageModel);

      // Act
      final result = await repository.getFiles(
        page: 0,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      expect(result.files.length, 1);
    });

    test('should handle large page number', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 999,
        pageSize: 50,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 999,
            pageSize: 50,
            type: null,
            status: null,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      when(() => mockRemoteDataSource.getFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
            type: any(named: 'type'),
            status: any(named: 'status'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getFiles(
        page: 0,
        pageSize: 1000,
        filter: FileFilter.all,
      );

      // Assert
      verify(() => mockRemoteDataSource.getFiles(
            page: 0,
            pageSize: 1000,
            type: null,
            status: null,
          )).called(1);
    });
  });
}
