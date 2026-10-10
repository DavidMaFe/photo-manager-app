import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/enums/file_status.dart';
import 'package:photo_manager_app/core/enums/file_type.dart';
import 'package:photo_manager_app/features/trash/data/data_sources/trash_remote_data_source.dart';
import 'package:photo_manager_app/features/trash/data/models/trash_file_model.dart';
import 'package:photo_manager_app/features/trash/data/models/trash_page_model.dart';
import 'package:photo_manager_app/features/trash/data/repositories/trash_repository_impl.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_page.dart';
import '../../../../helpers/recording_file_key_repository.dart';

class MockTrashRemoteDataSource extends Mock
    implements TrashRemoteDataSource {}

void main() {
  late TrashRepositoryImpl repository;
  late MockTrashRemoteDataSource mockRemoteDataSource;
  late RecordingFileKeyRepository fileKeys;

  setUp(() {
    mockRemoteDataSource = MockTrashRemoteDataSource();
    fileKeys = RecordingFileKeyRepository();
    repository = TrashRepositoryImpl(remoteDataSource: mockRemoteDataSource, fileKeyRepository: fileKeys);
  });

  final testCapturedDate = DateTime(2024, 1, 15);
  final testDeletedDate = DateTime(2024, 1, 25);

  final testFiles = [
    TrashFileModel(
      id: 'file-1',
      type: FileType.image,
      status: FileStatus.managed,
      capturedAt: testCapturedDate,
      deletedAt: testDeletedDate,
      sizeBytes: 1024,
    ),
    TrashFileModel(
      id: 'file-2',
      type: FileType.video,
      status: FileStatus.pending,
      capturedAt: testCapturedDate,
      deletedAt: testDeletedDate,
      sizeBytes: 2048,
      durationSeconds: 120,
    ),
  ];

  final testPageModel = TrashPageModel(
    files: testFiles,
    currentPage: 0,
    pageSize: 50,
    hasNext: true,
  );

  group('TrashRepositoryImpl - getTrashFiles', () {
    test('should remember the keys of the trashed files to decrypt their thumbnails', () async {
      final withKey = TrashFileModel(
        id: 'file-3',
        type: FileType.image,
        status: FileStatus.managed,
        capturedAt: testCapturedDate,
        deletedAt: testDeletedDate,
        sizeBytes: 10,
        encryptedRef: RecordingFileKeyRepository.ref('file-3'),
      );
      when(() => mockRemoteDataSource.getTrashFiles(page: any(named: 'page'), pageSize: any(named: 'pageSize')))
          .thenAnswer((_) async => TrashPageModel(files: [...testFiles, withKey], currentPage: 0, pageSize: 50,
              hasNext: false));

      await repository.getTrashFiles(page: 0, pageSize: 50);

      expect(fileKeys.remembered.map((ref) => ref.fileId), ['file-3']);
    });

    test('should call remote data source with correct parameters', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: 0,
            pageSize: 50,
          )).called(1);
    });

    test('should return TrashPage entity from data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      final result = await repository.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      expect(result, isA<TrashPage>());
      expect(result.files.length, 2);
      expect(result.currentPage, 0);
      expect(result.pageSize, 50);
      expect(result.hasNext, true);
    });

    test('should handle different page numbers', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 3, pageSize: 50);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: 3,
            pageSize: 50,
          )).called(1);
    });

    test('should handle different page sizes', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 0, pageSize: 100);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: 0,
            pageSize: 100,
          )).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.getTrashFiles(page: 0, pageSize: 50),
        throwsException,
      );
    });

    test('should return empty page when data source returns empty', () async {
      // Arrange
      const emptyPageModel = TrashPageModel(
        files: [],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => emptyPageModel);

      // Act
      final result = await repository.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      expect(result.files, isEmpty);
      expect(result.hasNext, false);
    });

    test('should call data source only once per request', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).called(1);
    });

    test('should handle page with single file', () async {
      // Arrange
      final singleFilePageModel = TrashPageModel(
        files: [testFiles.first],
        currentPage: 0,
        pageSize: 50,
        hasNext: false,
      );

      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => singleFilePageModel);

      // Act
      final result = await repository.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      expect(result.files.length, 1);
    });

    test('should handle large page number', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 999, pageSize: 50);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: 999,
            pageSize: 50,
          )).called(1);
    });

    test('should handle large page size', () async {
      // Arrange
      when(() => mockRemoteDataSource.getTrashFiles(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          )).thenAnswer((_) async => testPageModel);

      // Act
      await repository.getTrashFiles(page: 0, pageSize: 1000);

      // Assert
      verify(() => mockRemoteDataSource.getTrashFiles(
            page: 0,
            pageSize: 1000,
          )).called(1);
    });
  });

  group('TrashRepositoryImpl - restoreFiles', () {
    test('should call remote data source with file IDs', () async {
      // Arrange
      final fileIds = ['file-1', 'file-2'];
      when(() => mockRemoteDataSource.restoreFiles(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.restoreFiles(fileIds);

      // Assert
      verify(() => mockRemoteDataSource.restoreFiles(fileIds)).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.restoreFiles(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.restoreFiles(['file-1']),
        throwsException,
      );
    });

    test('should complete successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.restoreFiles(any()))
          .thenAnswer((_) async => {});

      // Act & Assert
      await expectLater(
        repository.restoreFiles(['file-1']),
        completes,
      );
    });
  });

  group('TrashRepositoryImpl - permanentlyDeleteFiles', () {
    test('should call remote data source with file IDs', () async {
      // Arrange
      final fileIds = ['file-1', 'file-2'];
      when(() => mockRemoteDataSource.permanentlyDeleteFiles(any()))
          .thenAnswer((_) async => {});

      // Act
      await repository.permanentlyDeleteFiles(fileIds);

      // Assert
      verify(() => mockRemoteDataSource.permanentlyDeleteFiles(fileIds))
          .called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.permanentlyDeleteFiles(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.permanentlyDeleteFiles(['file-1']),
        throwsException,
      );
    });

    test('should complete successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.permanentlyDeleteFiles(any()))
          .thenAnswer((_) async => {});

      // Act & Assert
      await expectLater(
        repository.permanentlyDeleteFiles(['file-1']),
        completes,
      );
    });
  });

  group('TrashRepositoryImpl - emptyTrash', () {
    test('should call remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.emptyTrash())
          .thenAnswer((_) async => {});

      // Act
      await repository.emptyTrash();

      // Assert
      verify(() => mockRemoteDataSource.emptyTrash()).called(1);
    });

    test('should propagate errors from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.emptyTrash())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.emptyTrash(),
        throwsException,
      );
    });

    test('should complete successfully', () async {
      // Arrange
      when(() => mockRemoteDataSource.emptyTrash())
          .thenAnswer((_) async => {});

      // Act & Assert
      await expectLater(
        repository.emptyTrash(),
        completes,
      );
    });
  });
}
