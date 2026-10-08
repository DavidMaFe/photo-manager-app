import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_session_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/data/models/duplicate_files_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/sync_session_model.dart';
import 'package:photo_manager_app/features/sync_session/data/models/upload_result_model.dart';
import 'package:photo_manager_app/features/sync_session/data/repositories/sync_session_repository_impl.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';

class MockSyncSessionRemoteDataSource extends Mock implements SyncSessionRemoteDataSource {}
class FakeEncryptedUpload extends Fake implements EncryptedUpload {}

void main() {
  late SyncSessionRepositoryImpl repository;
  late MockSyncSessionRemoteDataSource mockRemoteDataSource;

  setUpAll(() {
    registerFallbackValue(FakeEncryptedUpload());
  });

  setUp(() {
    mockRemoteDataSource = MockSyncSessionRemoteDataSource();
    repository = SyncSessionRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  group('startSyncSession', () {
    const deviceUuid = 'device-uuid-123';
    final syncSessionModel = SyncSessionModel(
      id: 'session-123',
      lastCompletedAt: DateTime(2024, 1, 15),
    );

    test('should call remote data source with device UUID', () async {
      // Arrange
      when(() => mockRemoteDataSource.startSyncSession(any()))
          .thenAnswer((_) async => syncSessionModel);

      // Act
      await repository.startSyncSession(deviceUuid: deviceUuid);

      // Assert
      verify(() => mockRemoteDataSource.startSyncSession(deviceUuid)).called(1);
    });

    test('should return SyncSession entity from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.startSyncSession(any()))
          .thenAnswer((_) async => syncSessionModel);

      // Act
      final result = await repository.startSyncSession(deviceUuid: deviceUuid);

      // Assert
      expect(result.id, syncSessionModel.id);
      expect(result.lastCompletedAt, syncSessionModel.lastCompletedAt);
    });

    test('should propagate exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.startSyncSession(any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.startSyncSession(deviceUuid: deviceUuid),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('checkDuplicates', () {
    const sessionId = 'session-123';
    final fileHashes = ['hash1', 'hash2', 'hash3'];
    final duplicateResult = DuplicateFilesResultModel(
      filesToUpload: ['hash1', 'hash3'],
      duplicatesCount: 1,
      totalFiles: 3,
    );

    test('should call remote data source with session ID and file hashes', () async {
      // Arrange
      when(() => mockRemoteDataSource.checkDuplicates(any(), any()))
          .thenAnswer((_) async => duplicateResult);

      // Act
      await repository.checkDuplicates(sessionId: sessionId, fileHashes: fileHashes);

      // Assert
      verify(() => mockRemoteDataSource.checkDuplicates(sessionId, fileHashes)).called(1);
    });

    test('should return DuplicateFilesResult entity from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.checkDuplicates(any(), any()))
          .thenAnswer((_) async => duplicateResult);

      // Act
      final result = await repository.checkDuplicates(
        sessionId: sessionId,
        fileHashes: fileHashes,
      );

      // Assert
      expect(result.filesToUpload, duplicateResult.filesToUpload);
      expect(result.duplicatesCount, duplicateResult.duplicatesCount);
      expect(result.totalFiles, duplicateResult.totalFiles);
    });

    test('should propagate exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.checkDuplicates(any(), any()))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => repository.checkDuplicates(sessionId: sessionId, fileHashes: fileHashes),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('uploadFile', () {
    const sessionId = 'session-123';
    final upload = EncryptedUpload(
      encryptedFile: File('/tmp/1.pmef'),
      encryptedThumbnail: null,
      dedupHash: 'a' * 64,
      isVideo: false,
      capturedAt: DateTime(2024, 1, 15),
      keyVersion: 1,
      encryptedFileKey: Uint8List(72),
      encryptedMetadata: Uint8List(50),
    );
    const uploadResult = UploadResultModel(fileId: 'server-file-456');

    test('should send the encrypted upload and return the server file ID', () async {
      when(() => mockRemoteDataSource.uploadFile(any(), any())).thenAnswer((_) async => uploadResult);

      final result = await repository.uploadFile(sessionId: sessionId, upload: upload);

      expect(result, 'server-file-456');
      verify(() => mockRemoteDataSource.uploadFile(sessionId, upload)).called(1);
    });

    test('should propagate exception from remote data source', () async {
      when(() => mockRemoteDataSource.uploadFile(any(), any())).thenThrow(Exception('Upload failed'));

      expect(() => repository.uploadFile(sessionId: sessionId, upload: upload), throwsA(isA<Exception>()));
    });
  });

  group('completeSyncSession', () {
    const sessionId = 'session-123';
    final syncResult = SyncResultModel(
      totalFiles: 100,
      uploadedFiles: 95,
      failedFiles: 5,
    );

    test('should call remote data source with session ID', () async {
      // Arrange
      when(() => mockRemoteDataSource.completeSyncSession(any()))
          .thenAnswer((_) async => syncResult);

      // Act
      await repository.completeSyncSession(sessionId: sessionId);

      // Assert
      verify(() => mockRemoteDataSource.completeSyncSession(sessionId)).called(1);
    });

    test('should return SyncResult entity from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.completeSyncSession(any()))
          .thenAnswer((_) async => syncResult);

      // Act
      final result = await repository.completeSyncSession(sessionId: sessionId);

      // Assert
      expect(result.totalFiles, syncResult.totalFiles);
      expect(result.uploadedFiles, syncResult.uploadedFiles);
      expect(result.failedFiles, syncResult.failedFiles);
    });

    test('should propagate exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.completeSyncSession(any()))
          .thenThrow(Exception('Session not found'));

      // Act & Assert
      expect(
        () => repository.completeSyncSession(sessionId: sessionId),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('cancelSyncSession', () {
    const sessionId = 'session-123';

    test('should call remote data source with session ID', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelSyncSession(any()))
          .thenAnswer((_) async => Future.value());

      // Act
      await repository.cancelSyncSession(sessionId: sessionId);

      // Assert
      verify(() => mockRemoteDataSource.cancelSyncSession(sessionId)).called(1);
    });

    test('should complete successfully when remote data source succeeds', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelSyncSession(any()))
          .thenAnswer((_) async => Future.value());

      // Act & Assert
      await expectLater(
        repository.cancelSyncSession(sessionId: sessionId),
        completes,
      );
    });

    test('should propagate exception from remote data source', () async {
      // Arrange
      when(() => mockRemoteDataSource.cancelSyncSession(any()))
          .thenThrow(Exception('Cancellation failed'));

      // Act & Assert
      expect(
        () => repository.cancelSyncSession(sessionId: sessionId),
        throwsA(isA<Exception>()),
      );
    });
  });
}