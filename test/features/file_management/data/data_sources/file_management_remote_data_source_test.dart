import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/file_management/data/data_sources/file_management_remote_data_source.dart';
import 'package:photo_manager_app/features/file_management/data/models/manage_file_request_model.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

void main() {
  late FileManagementRemoteDataSourceImpl dataSource;
  late MockHttpClient mockClient;

  const baseUrl = DataConstants.backendBaseUrl;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockClient = MockHttpClient();
    dataSource = FileManagementRemoteDataSourceImpl(
      client: mockClient,
      baseUrl: baseUrl,
    );
  });

  group('manageFiles', () {
    const fileIds = ['file-1', 'file-2', 'file-3'];
    const request = ManageFileRequestModel(
      fileIds: fileIds,
      serverAction: 'SAVE',
      keepOnDevice: true,
    );

    test('should return ManageFileResponseModel on successful request', () async {
      // Arrange
      final responseBody = jsonEncode({
        'successfulFiles': ['file-1', 'file-2', 'file-3'],
        'failedFiles': [],
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.manageFiles(request);

      // Assert
      expect(result.successfulIds, ['file-1', 'file-2', 'file-3']);
      expect(result.failedIds, isEmpty);
    });

    test('should call correct endpoint with POST method', () async {
      // Arrange
      final responseBody = jsonEncode({
        'successfulFiles': [],
        'failedFiles': [],
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.manageFiles(request);

      // Assert
      final captured = verify(() => mockClient.post(
            Uri.parse('$baseUrl/api/file/manage/'),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });

    test('should include request body in POST', () async {
      // Arrange
      final responseBody = jsonEncode({
        'successfulFiles': fileIds,
        'failedFiles': [],
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.manageFiles(request);

      // Assert
      final captured = verify(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: captureAny(named: 'body'),
          )).captured;

      final body = jsonDecode(captured.first);
      expect(body['filesToManage'], fileIds);
      expect(body['manageAction'], 'SAVE');
      expect(body['keepOnDevice'], true);
    });

    test('should handle partial success response', () async {
      // Arrange
      final responseBody = jsonEncode({
        'successfulFiles': ['file-1', 'file-2'],
        'failedFiles': ['file-3'],
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.manageFiles(request);

      // Assert
      expect(result.successfulIds, ['file-1', 'file-2']);
      expect(result.failedIds, ['file-3']);
    });

    test('should throw ApiException on 400 error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'BAD_REQUEST',
              'message': 'Bad request',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/file/manage/',
            }),
            400,
          ));

      // Act & Assert
      expect(
        () => dataSource.manageFiles(request),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'BAD_REQUEST' &&
              e.message == 'Bad request'),
        ),
      );
    });

    test('should throw ApiException on 404 error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'FILES_NOT_FOUND',
              'message': 'Files not found',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/file/manage/',
            }),
            404,
          ));

      // Act & Assert
      expect(
        () => dataSource.manageFiles(request),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'FILES_NOT_FOUND' &&
              e.message == 'Files not found'),
        ),
      );
    });

    test('should throw ApiException on 500 error', () async {
      // Arrange
      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Server error',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/file/manage/',
            }),
            500,
          ));

      // Act & Assert
      expect(
        () => dataSource.manageFiles(request),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'INTERNAL_SERVER_ERROR' &&
              e.message == 'Server error'),
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
        () => dataSource.manageFiles(request),
        throwsA(exception),
      );
    });

    test('should include authorization header', () async {
      // Arrange
      final responseBody = jsonEncode({
        'successfulFiles': [],
        'failedFiles': [],
      });

      when(() => mockClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.manageFiles(request);

      // Assert
      final captured = verify(() => mockClient.post(
            any(),
            headers: captureAny(named: 'headers'),
            body: any(named: 'body'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });
  });

  group('getFolders', () {
    test('should return list of ManageFolderModel on success', () async {
      // Arrange
      final responseBody = jsonEncode({
        'folders': [
          {
            'id': 'folder-1',
            'name': 'Vacation',
            'filesQuantity': 42,
            'createdAt': '2024-01-15T10:30:00.000Z',
          },
          {
            'id': 'folder-2',
            'name': 'Work',
            'filesQuantity': 15,
            'createdAt': '2024-01-16T10:30:00.000Z',
          },
        ],
      });

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getFolders();

      // Assert
      expect(result.length, 2);
      expect(result[0].id, 'folder-1');
      expect(result[0].name, 'Vacation');
      expect(result[0].fileCount, 42);
      expect(result[1].id, 'folder-2');
      expect(result[1].name, 'Work');
    });

    test('should call correct endpoint with GET method', () async {
      // Arrange
      final responseBody = jsonEncode({'folders': []});

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getFolders();

      // Assert
      final captured = verify(() => mockClient.get(
            Uri.parse('$baseUrl/api/folder/list/'),
            headers: captureAny(named: 'headers'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });

    test('should return empty list when no folders', () async {
      // Arrange
      final responseBody = jsonEncode({'folders': []});

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getFolders();

      // Assert
      expect(result, isEmpty);
    });

    test('should handle missing folders field', () async {
      // Arrange
      final responseBody = jsonEncode({});

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getFolders();

      // Assert
      expect(result, isEmpty);
    });

    test('should throw ApiException on 401 error', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'UNAUTHORIZED',
              'message': 'Unauthorized',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/folder/list/',
            }),
            401,
          ));

      // Act & Assert
      expect(
        () => dataSource.getFolders(),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'UNAUTHORIZED' &&
              e.message == 'Unauthorized'),
        ),
      );
    });

    test('should throw ApiException on 500 error', () async {
      // Arrange
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Server error',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/folder/list/',
            }),
            500,
          ));

      // Act & Assert
      expect(
        () => dataSource.getFolders(),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'INTERNAL_SERVER_ERROR' &&
              e.message == 'Server error'),
        ),
      );
    });

    test('should rethrow SocketException on network error', () async {
      // Arrange
      const exception = SocketException('Network error');
      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.getFolders(),
        throwsA(exception),
      );
    });

    test('should include authorization header', () async {
      // Arrange
      final responseBody = jsonEncode({'folders': []});

      when(() => mockClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getFolders();

      // Assert
      final captured = verify(() => mockClient.get(
            any(),
            headers: captureAny(named: 'headers'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });
  });
}
