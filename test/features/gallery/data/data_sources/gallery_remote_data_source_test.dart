import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/gallery/data/data_sources/gallery_remote_data_source.dart';
import 'package:photo_manager_app/features/gallery/data/models/gallery_page_model.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });
  late GalleryRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  const baseUrl = 'http://localhost:8080';
  const testToken = 'test-token-123';

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    dataSource = GalleryRemoteDataSourceImpl(
      client: mockHttpClient,
      authLocalDataSource: mockAuthLocalDataSource,
      baseUrl: baseUrl,
    );

    when(() => mockAuthLocalDataSource.getToken())
        .thenAnswer((_) async => testToken);
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
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/file/list/')
                .replace(queryParameters: {
              'page': '0',
              'pageSize': '50',
              'isDeleted': 'false',
            }),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $testToken',
            },
          )).called(1);
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

    test('should throw HttpException on non-200 status code', () async {
      // Arrange
      final responseBody = jsonEncode({'message': 'Unauthorized'});

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 401));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw HttpException with error message on 400', () async {
      // Arrange
      final responseBody = jsonEncode({'message': 'Bad request'});

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 400));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw HttpException on 404', () async {
      // Arrange
      final responseBody = jsonEncode({'message': 'Not found'});

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 404));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw HttpException on 500', () async {
      // Arrange
      final responseBody = jsonEncode({'message': 'Internal server error'});

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 500));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw Exception on network error', () async {
      // Arrange
      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenThrow(const SocketException('Network error'));

      // Act & Assert
      expect(
        () => dataSource.getFiles(page: 0, pageSize: 50),
        throwsA(isA<Exception>()),
      );
    });

    test('should use auth token from local data source', () async {
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
      verify(() => mockAuthLocalDataSource.getToken()).called(1);
      verify(() => mockHttpClient.get(
            any(),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $testToken',
            },
          )).called(1);
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
