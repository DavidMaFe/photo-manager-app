import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_file.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/upload_result.dart';
import 'package:photo_manager_app/features/sync_session/domain/repositories/sync_session_repository.dart';
import 'package:photo_manager_app/features/sync_session/domain/use_cases/upload_file_use_case.dart';

class MockSyncSessionRepository extends Mock implements SyncSessionRepository {}

class FakeSyncFile extends Fake implements SyncFile {}

void main() {
  late UploadFileUseCase useCase;
  late MockSyncSessionRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeSyncFile());
  });

  setUp(() {
    mockRepository = MockSyncSessionRepository();
    useCase = UploadFileUseCase(mockRepository);
  });

  group('UploadFileUseCase', () {
    const sessionId = 'session_123';
    const serverFileId = 'server_file_456';
    final syncFile = SyncFile(
      localId: 'local_123',
      devicePath: '/storage/photo.jpg',
      hash: 'abc123',
      fileName: 'photo.jpg',
      sizeBytes: 1048576,
      capturedAt: DateTime(2024, 1, 15),
      mimeType: 'image/jpeg',
    );

    test('should call repository with correct parameters', () async {
      // Arrange
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenAnswer((_) async => serverFileId);

      // Act
      await useCase(sessionId: sessionId, file: syncFile);

      // Assert
      verify(() => mockRepository.uploadFile(
            sessionId: sessionId,
            file: syncFile,
          )).called(1);
    });

    test('should return UploadResult with server file ID', () async {
      // Arrange
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenAnswer((_) async => serverFileId);

      // Act
      final result = await useCase(sessionId: sessionId, file: syncFile);

      // Assert
      expect(result, isA<UploadResult>());
      expect(result.serverFileId, serverFileId);
    });

    test('should throw exception when session ID is empty', () async {
      // Act & Assert
      expect(
        () => useCase(sessionId: '', file: syncFile),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );

      verifyNever(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          ));
    });

    test('should throw exception when session ID is only whitespace', () async {
      // Act & Assert
      expect(
        () => useCase(sessionId: '   ', file: syncFile),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Invalid Sync Session ID'),
        )),
      );
    });

    test('should pass session ID as-is to repository (no trimming)', () async {
      // Arrange
      const sessionIdWithSpaces = '  session_123  ';
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenAnswer((_) async => serverFileId);

      // Act
      await useCase(sessionId: sessionIdWithSpaces, file: syncFile);

      // Assert
      verify(() => mockRepository.uploadFile(
            sessionId: sessionIdWithSpaces,
            file: syncFile,
          )).called(1);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenThrow(Exception('Upload failed'));

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, file: syncFile),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Upload failed'),
        )),
      );
    });

    test('should handle upload of video file', () async {
      // Arrange
      final videoFile = SyncFile(
        localId: 'local_456',
        devicePath: '/storage/video.mp4',
        hash: 'def456',
        fileName: 'video.mp4',
        sizeBytes: 10485760,
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'video/mp4',
        durationSeconds: 120,
      );
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenAnswer((_) async => 'server_video_789');

      // Act
      final result = await useCase(sessionId: sessionId, file: videoFile);

      // Assert
      expect(result.serverFileId, 'server_video_789');
      verify(() => mockRepository.uploadFile(
            sessionId: sessionId,
            file: videoFile,
          )).called(1);
    });

    test('should handle large file upload', () async {
      // Arrange
      final largeFile = SyncFile(
        localId: 'local_789',
        devicePath: '/storage/large.mp4',
        hash: 'ghi789',
        fileName: 'large.mp4',
        sizeBytes: 104857600, // 100 MB
        capturedAt: DateTime(2024, 1, 15),
        mimeType: 'video/mp4',
      );
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenAnswer((_) async => 'server_large_999');

      // Act
      final result = await useCase(sessionId: sessionId, file: largeFile);

      // Assert
      expect(result.serverFileId, 'server_large_999');
    });

    test('should handle network interruption during upload', () async {
      // Arrange
      when(() => mockRepository.uploadFile(
            sessionId: any(named: 'sessionId'),
            file: any(named: 'file'),
          )).thenThrow(Exception('Connection lost'));

      // Act & Assert
      expect(
        () => useCase(sessionId: sessionId, file: syncFile),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Connection lost'),
        )),
      );
    });
  });
}