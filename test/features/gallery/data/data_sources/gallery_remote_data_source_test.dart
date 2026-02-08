import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_page_model.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });
  late GalleryRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  const baseUrl = 'http://localhost:8080';

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = GalleryRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: baseUrl,
    );
  });

  group('GalleryRemoteDataSource - getFiles', () {
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
      await dataSource.getFiles(page: 0, pageSize: 50);

      // Assert
      final captured = verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/')
                .replace(queryParameters: {
              'page': '0',
              'pageSize': '50',
              'isDeleted': 'false',
            }),
            headers: captureAny(named: 'headers'),
          ));
      captured.called(1);

      final headers = captured.captured.last as Map<String, String>;
      expect(headers['Content-Type'], 'application/json');
      expect(headers.containsKey('Accept-Language'), true);
    });

    test('should return GalleryPageModel on successful response', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [
          {
            'id': 123,
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
        ],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getFiles(page: 0, pageSize: 50);

      // Assert
      expect(result, isA<GalleryPageModel>());
      expect(result.files.length, 1);
      expect(result.files[0].id, '123');
      expect(result.currentPage, 0);
      expect(result.pageSize, 50);
      expect(result.hasNext, true);
    });

    test('should include type parameter in query when provided', () async {
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
      await dataSource.getFiles(page: 0, pageSize: 50, type: 'IMAGE');

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '0',
                'pageSize': '50',
                'isDeleted': 'false',
                'type': 'IMAGE',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should include status parameter in query when provided', () async {
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
      await dataSource.getFiles(page: 0, pageSize: 50, status: 'PENDING');

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '0',
                'pageSize': '50',
                'isDeleted': 'false',
                'status': 'PENDING',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should include both type and status parameters when provided', () async {
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
      await dataSource.getFiles(
        page: 0,
        pageSize: 50,
        type: 'VIDEO',
        status: 'PENDING',
      );

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '0',
                'pageSize': '50',
                'isDeleted': 'false',
                'type': 'VIDEO',
                'status': 'PENDING',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
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
      await dataSource.getFiles(page: 3, pageSize: 50);

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '3',
                'pageSize': '50',
                'isDeleted': 'false',
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
      await dataSource.getFiles(page: 0, pageSize: 100);

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/').replace(
              queryParameters: {
                'page': '0',
                'pageSize': '100',
                'isDeleted': 'false',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should always include isDeleted=false in query', () async {
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
      await dataSource.getFiles(page: 0, pageSize: 50);

      // Assert
      final captured = verify(() => mockHttpClient.get(
            captureAny(),
            headers: any(named: 'headers'),
          )).captured.first as Uri;

      expect(captured.queryParameters['isDeleted'], 'false');
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
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'UNAUTHORIZED' &&
              e.message == 'Unauthorized'),
        ),
      );
    });

    test('should throw ApiException with error message on 400', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'BAD_REQUEST',
        'message': 'Bad request',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/list/',
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 400));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'BAD_REQUEST' &&
              e.message == 'Bad request'),
        ),
      );
    });

    test('should throw ApiException on 404', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'NOT_FOUND',
        'message': 'Not found',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/list/',
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 404));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'NOT_FOUND' &&
              e.message == 'Not found'),
        ),
      );
    });

    test('should throw ApiException on 500', () async {
      // Arrange
      final responseBody = jsonEncode({
        'code': 'INTERNAL_SERVER_ERROR',
        'message': 'Internal server error',
        'timestamp': '2025-01-26T10:30:45.123456',
        'path': '/api/file/list/',
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 500));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(
          predicate((e) =>
              e is ApiException &&
              e.code == 'INTERNAL_SERVER_ERROR' &&
              e.message == 'Internal server error'),
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
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(exception),
      );
    });

    test('should handle empty files list', () async {
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
      final result = await dataSource.getFiles(page: 0, pageSize: 50);

      // Assert
      expect(result.files, isEmpty);
      expect(result.hasNext, false);
    });

    test('should handle multiple files in response', () async {
      // Arrange
      final responseBody = jsonEncode({
        'files': [
          {
            'id': 1,
            'type': 'IMAGE',
            'status': 'MANAGED',
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
          {
            'id': 2,
            'type': 'VIDEO',
            'status': 'PENDING',
            'durationSecionds': 120,
            'capturedAt': '2024-01-15T10:30:00.000Z',
          },
        ],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getFiles(page: 0, pageSize: 50);

      // Assert
      expect(result.files.length, 2);
      expect(result.files[0].id, '1');
      expect(result.files[1].id, '2');
    });
  });
}
