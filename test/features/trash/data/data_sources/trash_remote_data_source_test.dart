import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/trash/data/data_sources/trash_remote_data_source.dart';
import 'package:photo_manager_app/features/trash/data/models/trash_page_model.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  late TrashRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  const baseUrl = 'http://localhost:8080';

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = TrashRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: baseUrl,
    );
  });

  group('TrashRemoteDataSource - getTrashFiles', () {
    test('should perform GET request with correct endpoint and headers', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      final captured = verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/')
                .replace(queryParameters: {
              'page': '0',
              'pageSize': '50',
              'isDeleted': 'true',
            }),
            headers: captureAny(named: 'headers'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });

    test('should return TrashPageModel on successful response', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [
          {
            'id': 123,
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-01-15T10:30:00.000Z',
            'deletedAt': '2024-01-25T14:20:00.000Z',
            'sizeBytes': 1024,
          },
        ],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      expect(result, isA<TrashPageModel>());
      expect(result.files.length, 1);
      expect(result.files[0].id, '123');
      expect(result.currentPage, 0);
      expect(result.pageSize, 50);
      expect(result.hasNext, true);
    });

    test('should handle different page numbers', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getTrashFiles(page: 3, pageSize: 50);

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '3',
                'pageSize': '50',
                'isDeleted': 'true',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should handle different page sizes', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getTrashFiles(page: 0, pageSize: 100);

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '0',
                'pageSize': '100',
                'isDeleted': 'true',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should always include isDeleted=true in query', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getTrashFiles(page: 0, pageSize: 50);

      // Assert
      final captured = verify(() => mockHttpClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured.first as Uri;

      expect(captured.queryParameters['isDeleted'], 'true');
    });

    test('should throw ApiException on non-200 status code', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'UNAUTHORIZED',
        'message': 'Unauthorized',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/list/',
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 401));

      // Act & Assert
      expect(
        () => dataSource.getTrashFiles(page: 0, pageSize: 50),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'UNAUTHORIZED' &&
              e.message == 'Unauthorized'),
        ),
      );
    });

    test('should rethrow SocketException on network error', () async {
      // Arrange
      const exception = SocketException('Network error');
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.getTrashFiles(page: 0, pageSize: 50),
        throwsA(isA<SocketException>()),
      );
    });

    test('should rethrow HttpException', () async {
      // Arrange
      final exception = HttpException('HTTP error');
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.getTrashFiles(page: 0, pageSize: 50),
        throwsA(isA<HttpException>()),
      );
    });
  });

  group('TrashRemoteDataSource - restoreFiles', () {
    test('should perform POST request with correct endpoint and headers', () async {
      // Arrange
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act
      await dataSource.restoreFiles(['file-1', 'file-2']);

      // Assert
      final captured = verify(() => mockHttpClient.post(
            Uri.parse('$baseUrl/api/file/restore/'),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          ));
      captured.called(1);

      final headers = captured.captured[0] as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');

      final body = captured.captured[1] as String;
      final bodyJson = jsonDecode(body) as Map<String, dynamic>;
      expect(bodyJson['fileIds'], ['file-1', 'file-2']);
    });

    test('should return successfully on 200 status code', () async {
      // Arrange
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      await expectLater(
        dataSource.restoreFiles(['file-1']),
        completes,
      );
    });

    test('should return successfully on 204 status code', () async {
      // Arrange
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 204));

      // Act & Assert
      await expectLater(
        dataSource.restoreFiles(['file-1']),
        completes,
      );
    });

    test('should throw ApiException on non-success status code', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'NOT_FOUND',
        'message': 'File not found',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/restore/',
      });

      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 404));

      // Act & Assert
      expect(
        () => dataSource.restoreFiles(['file-1']),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'NOT_FOUND' &&
              e.message == 'File not found'),
        ),
      );
    });

    test('should rethrow SocketException on network error', () async {
      // Arrange
      const exception = SocketException('Network error');
      when(() => mockHttpClient.post(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.restoreFiles(['file-1']),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('TrashRemoteDataSource - permanentlyDeleteFiles', () {
    test('should perform DELETE request with correct endpoint and headers', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act
      await dataSource.permanentlyDeleteFiles(['file-1', 'file-2']);

      // Assert
      final captured = verify(() => mockHttpClient.delete(
            Uri.parse('$baseUrl/api/file/delete-permanently/'),
            headers: captureAny(named: 'headers'),
            body: captureAny(named: 'body'),
          ));
      captured.called(1);

      final headers = captured.captured[0] as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');

      final body = captured.captured[1] as String;
      final bodyJson = jsonDecode(body) as Map<String, dynamic>;
      expect(bodyJson['fileIds'], ['file-1', 'file-2']);
    });

    test('should return successfully on 200 status code', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      await expectLater(
        dataSource.permanentlyDeleteFiles(['file-1']),
        completes,
      );
    });

    test('should return successfully on 204 status code', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response('', 204));

      // Act & Assert
      await expectLater(
        dataSource.permanentlyDeleteFiles(['file-1']),
        completes,
      );
    });

    test('should throw ApiException on non-success status code', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'FORBIDDEN',
        'message': 'Access denied',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/delete-permanently/',
      });

      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenAnswer((_) async => http.Response(responseBody, 403));

      // Act & Assert
      expect(
        () => dataSource.permanentlyDeleteFiles(['file-1']),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'FORBIDDEN' &&
              e.message == 'Access denied'),
        ),
      );
    });

    test('should rethrow SocketException on network error', () async {
      // Arrange
      const exception = SocketException('Network error');
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.permanentlyDeleteFiles(['file-1']),
        throwsA(isA<SocketException>()),
      );
    });
  });

  group('TrashRemoteDataSource - emptyTrash', () {
    test('should perform DELETE request with correct endpoint and headers', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act
      await dataSource.emptyTrash();

      // Assert
      final captured = verify(() => mockHttpClient.delete(
            Uri.parse('$baseUrl/api/file/empty-trash/'),
            headers: captureAny(named: 'headers'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
    });

    test('should return successfully on 200 status code', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('', 200));

      // Act & Assert
      await expectLater(
        dataSource.emptyTrash(),
        completes,
      );
    });

    test('should return successfully on 204 status code', () async {
      // Arrange
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response('', 204));

      // Act & Assert
      await expectLater(
        dataSource.emptyTrash(),
        completes,
      );
    });

    test('should throw ApiException on non-success status code', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'INTERNAL_SERVER_ERROR',
        'message': 'Server error',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/empty-trash/',
      });

      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 500));

      // Act & Assert
      expect(
        () => dataSource.emptyTrash(),
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
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.emptyTrash(),
        throwsA(isA<SocketException>()),
      );
    });

    test('should rethrow HttpException', () async {
      // Arrange
      final exception = HttpException('HTTP error');
      when(() => mockHttpClient.delete(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(exception);

      // Act & Assert
      expect(
        () => dataSource.emptyTrash(),
        throwsA(isA<HttpException>()),
      );
    });
  });
}
