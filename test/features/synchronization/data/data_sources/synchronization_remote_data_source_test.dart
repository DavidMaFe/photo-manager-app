import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/synchronization/data/data_sources/synchronization_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}
class FakeUri extends Fake implements Uri {}

void main() {
  late SynchronizationRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  const baseUrl = 'http://localhost:8080';
  const testDeviceUuid = 'device-uuid-123';

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = SynchronizationRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: baseUrl,
    );
  });

  group('SynchronizationRemoteDataSource - getSynchronizations', () {
    test('should perform GET request with correct endpoint and headers', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/sync_session/list/').replace(
              queryParameters: {
                'deviceUuid': testDeviceUuid,
                'page': '0',
                'pageSize': '20',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should return SynchronizationsListResponse on success', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [
          {
            'syncSessionId': 123,
            'startedAt': '2024-01-15T10:30:00.000Z',
            'status': 'COMPLETED',
            'syncFiles': 100,
            'uploadedFiles': 100,
            'failedFiles': 0,
          },
        ],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result, isA<SynchronizationsListResponse>());
      expect(result.syncSessions.length, 1);
      expect(result.syncSessions[0].id, '123');
      expect(result.hasNext, true);
    });

    test('should handle different page numbers', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 3,
        pageSize: 20,
      );

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/sync_session/list/').replace(
              queryParameters: {
                'deviceUuid': testDeviceUuid,
                'page': '3',
                'pageSize': '20',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should handle different page sizes', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 50,
      );

      // Assert
      verify(() => mockHttpClient.get(
            Uri.parse('$baseUrl/api/sync_session/list/').replace(
              queryParameters: {
                'deviceUuid': testDeviceUuid,
                'page': '0',
                'pageSize': '50',
              },
            ),
            headers: any(named: 'headers'),
          )).called(1);
    });

    test('should handle empty sync sessions list', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.syncSessions, isEmpty);
      expect(result.hasNext, false);
    });

    test('should handle multiple sync sessions', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [
          {
            'syncSessionId': 1,
            'startedAt': '2024-01-15T10:30:00.000Z',
            'status': 'COMPLETED',
            'syncFiles': 100,
            'uploadedFiles': 100,
            'failedFiles': 0,
          },
          {
            'syncSessionId': 2,
            'startedAt': '2024-01-14T10:30:00.000Z',
            'status': 'FAILED',
            'syncFiles': 50,
            'uploadedFiles': 30,
            'failedFiles': 20,
          },
        ],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.syncSessions.length, 2);
      expect(result.syncSessions[0].id, '1');
      expect(result.syncSessions[1].id, '2');
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
        () => dataSource.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
        throwsA(isA<HttpException>()),
      );
    });

    test('should throw HttpException on 400', () async {
      // Arrange
      final responseBody = jsonEncode({'message': 'Bad request'});

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 400));

      // Act & Assert
      expect(
        () => dataSource.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
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
        () => dataSource.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
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
        () => dataSource.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
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
        () => dataSource.getSynchronizations(
          deviceUuid: testDeviceUuid,
          page: 0,
          pageSize: 20,
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle hasNext true', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': true,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.hasNext, true);
    });

    test('should handle hasNext false', () async {
      // Arrange
      final responseBody = jsonEncode({
        'syncSessions': [],
        'hasNext': false,
      });

      when(() => mockHttpClient.get(
            any(),
            headers: any(named: 'headers'),
          )).thenAnswer((_) async => http.Response(responseBody, 200));

      // Act
      final result = await dataSource.getSynchronizations(
        deviceUuid: testDeviceUuid,
        page: 0,
        pageSize: 20,
      );

      // Assert
      expect(result.hasNext, false);
    });
  });
}
