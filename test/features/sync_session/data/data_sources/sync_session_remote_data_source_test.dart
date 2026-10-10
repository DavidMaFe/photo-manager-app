import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/sync_session/data/data_sources/remote/sync_session_remote_data_source.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/encrypted_upload.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}
class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late SyncSessionRemoteDatasourceImpl dataSource;
  late MockHttpClient mockClient;

  const baseUrl = DataConstants.backendBaseUrl;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeBaseRequest());
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = SyncSessionRemoteDatasourceImpl(
      client: mockClient,
      baseUrl: baseUrl,
    );
  });

  group('startSyncSession', () {
    const deviceUuid = 'device-uuid-123';
    const sessionId = 'session-123';

    test('should return SyncSessionModel on successful response', () async {
      // Arrange
      final responseBody = jsonEncode({
        'sessionId': sessionId,
        'lastSyncCompletedAt': '2024-01-15T10:30:00.000Z',
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.startSyncSession(deviceUuid);

      // Assert
      expect(result.id, sessionId);
      final captured = verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/sync_session/start/'),
            headers: captureAny(named: 'headers'),
            body: jsonEncode({'deviceUuid': deviceUuid}),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });

    test('should throw ApiException on non-200 response', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'SESSION_CREATION_FAILED',
              'message': 'Session creation failed',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/sync_session/start/',
            }),
            400,
          ));

      // Act & Assert
      expect(
        () => dataSource.startSyncSession(deviceUuid),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'SESSION_CREATION_FAILED' &&
              e.message == 'Session creation failed'),
        ),
      );
    });

    test('should rethrow SocketException on network error', () async {
      // Arrange
      const exception = SocketException('Network error');
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.startSyncSession(deviceUuid),
        throwsA(exception),
      );
    });
  });

  group('checkDuplicates', () {
    const sessionId = 'session-123';
    final fileHashes = ['hash1', 'hash2', 'hash3'];

    test('should return DuplicateFilesResultModel on success', () async {
      // Arrange
      final responseBody = jsonEncode({
        'filesToUpload': ['hash1', 'hash3'],
        'duplicatedFiles': 1,
        'totalFilesToUpload': 3,
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.checkDuplicates(sessionId, fileHashes);

      // Assert
      expect(result.filesToUpload, ['hash1', 'hash3']);
      expect(result.duplicatesCount, 1);
      verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/sync_session/check_duplicates/'),
            headers: any(named: 'headers'),
            body: jsonEncode({
              'sessionId': sessionId,
              'fileHashes': fileHashes,
            }),
          )).called(1);
    });

    test('should throw ApiException on error response', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'INVALID_SESSION',
              'message': 'Invalid session',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/sync_session/check_duplicates/',
            }),
            404,
          ));

      // Act & Assert
      expect(
        () => dataSource.checkDuplicates(sessionId, fileHashes),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'INVALID_SESSION' &&
              e.message == 'Invalid session'),
        ),
      );
    });
  });

  group('completeSyncSession', () {
    const sessionId = 'session-123';

    test('should return SyncResultModel on success', () async {
      // Arrange
      final responseBody = jsonEncode({
        'totalFiles': 100,
        'filesUploaded': 95,
        'filesFailed': 5,
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.completeSyncSession(sessionId);

      // Assert
      expect(result.totalFiles, 100);
      expect(result.uploadedFiles, 95);
      expect(result.failedFiles, 5);
      verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/sync_session/complete/'),
            headers: any(named: 'headers'),
            body: jsonEncode({'sessionId': sessionId}),
          )).called(1);
    });

    test('should throw ApiException on error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'SESSION_NOT_FOUND',
              'message': 'Session not found',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/sync_session/complete/',
            }),
            404,
          ));

      // Act & Assert
      expect(
        () => dataSource.completeSyncSession(sessionId),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'SESSION_NOT_FOUND' &&
              e.message == 'Session not found'),
        ),
      );
    });
  });

  group('cancelSyncSession', () {
    const sessionId = 'session-123';

    test('should complete successfully on 200 response', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      await expectLater(
        dataSource.cancelSyncSession(sessionId),
        completes,
      );
      verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/sync_session/cancel/'),
            headers: any(named: 'headers'),
            body: jsonEncode({'sessionId': sessionId}),
          )).called(1);
    });

    test('should throw ApiException on error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'CANNOT_CANCEL_SESSION',
              'message': 'Cannot cancel',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/sync_session/cancel/',
            }),
            400,
          ));

      // Act & Assert
      expect(
        () => dataSource.cancelSyncSession(sessionId),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'CANNOT_CANCEL_SESSION' &&
              e.message == 'Cannot cancel'),
        ),
      );
    });
  });

  group('uploadFile', () {
    const sessionId = 'session-123';
    late Directory tempDir;
    late EncryptedUpload upload;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('upload_test');
      final encrypted = File('${tempDir.path}/1.pmef')..writeAsBytesSync(List.generate(100, (i) => i));
      upload = EncryptedUpload(
        encryptedFile: encrypted,
        encryptedThumbnail: Uint8List.fromList([9, 8, 7]),
        dedupHash: 'a' * 64,
        isVideo: true,
        capturedAt: DateTime(2024, 1, 15, 10, 30),
        width: 1920,
        height: 1080,
        durationSeconds: 12,
        keyVersion: 2,
        encryptedFileKey: Uint8List(72),
        encryptedMetadata: Uint8List.fromList(List.filled(50, 1)),
      );
    });

    tearDown(() => tempDir.delete(recursive: true));

    /// The body of the multipart request, as text (the binary parts are small).
    Future<String> sentBody(http.BaseRequest request) async =>
        latin1.decode(await request.finalize().expand((chunk) => chunk).toList());

    test('should send the encrypted file, the encrypted thumbnail and the metadata', () async {
      // Arrange
      late http.BaseRequest sent;
      late String body;
      when(() => mockClient.send(any())).thenAnswer((invocation) async {
        sent = invocation.positionalArguments.first as http.BaseRequest;
        body = await sentBody(sent);
        return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'fileId': 456}))), 200);
      });

      // Act
      final result = await dataSource.uploadFile(sessionId, upload);

      // Assert
      expect(result.fileId, '456');
      expect(sent.url.toString(), '$baseUrl/api/sync_session/upload/');
      final request = sent as http.MultipartRequest;
      expect(request.fields['sessionId'], sessionId);
      final metadata = jsonDecode(request.fields['metadata']!) as Map<String, dynamic>;
      expect(metadata, {
        'fileHash': 'a' * 64,
        'fileType': 'VIDEO',
        'capturedAt': '2024-01-15T10:30:00.000',
        'width': 1920,
        'height': 1080,
        'durationSeconds': 12,
        'keyVersion': 2,
        'encryptedFileKey': base64Encode(Uint8List(72)),
        'encryptedMetadata': base64Encode(List.filled(50, 1)),
      });
      expect(request.files.map((f) => f.field), ['file', 'thumbnail']);
      expect(request.files.map((f) => f.filename), ['file', 'thumbnail']);
      expect(request.files.first.length, 100);
      expect(body, contains('name="thumbnail"'));
    });

    test('should send no thumbnail part when there is none', () async {
      late http.MultipartRequest sent;
      when(() => mockClient.send(any())).thenAnswer((invocation) async {
        sent = invocation.positionalArguments.first as http.MultipartRequest;
        await sentBody(sent);
        return http.StreamedResponse(Stream.value(utf8.encode(jsonEncode({'fileId': 1}))), 200);
      });

      await dataSource.uploadFile(sessionId, EncryptedUpload(
        encryptedFile: upload.encryptedFile,
        encryptedThumbnail: null,
        dedupHash: upload.dedupHash,
        isVideo: false,
        capturedAt: upload.capturedAt,
        keyVersion: 1,
        encryptedFileKey: upload.encryptedFileKey,
        encryptedMetadata: upload.encryptedMetadata,
      ));

      expect(sent.files.map((f) => f.field), ['file']);
      final metadata = jsonDecode(sent.fields['metadata']!) as Map<String, dynamic>;
      expect(metadata['fileType'], 'IMAGE');
      expect(metadata.containsKey('durationSeconds'), isFalse);
    });

    test('should throw ApiException on upload failure', () async {
      final errorBody = jsonEncode({
        'code': 'INVALID_ENCRYPTED_FILE',
        'message': 'Not encrypted',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/sync_session/upload/',
      });
      when(() => mockClient.send(any())).thenAnswer((invocation) async {
        await sentBody(invocation.positionalArguments.first as http.BaseRequest);
        return http.StreamedResponse(Stream.value(utf8.encode(errorBody)), 400);
      });

      await expectLater(
        () => dataSource.uploadFile(sessionId, upload),
        throwsA(predicate((e) => e is ApiException && e.code == 'INVALID_ENCRYPTED_FILE')),
      );
    });
  });
}
