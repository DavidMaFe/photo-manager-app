import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class FakeUri extends Fake implements Uri {}

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  late MockAuthLocalDataSource mockAuthLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockAuthLocalDataSource = MockAuthLocalDataSource();
    dataSource = ProfileRemoteDataSourceImpl(
      client: mockHttpClient,
      authLocalDataSource: mockAuthLocalDataSource,
    );
  });

  group('ProfileRemoteDataSource', () {
    const testToken = 'test_token_123';
    const baseUrl = 'http://10.0.2.2:8080';

    final successResponse = {
      'id': '1',
      'email': 'test@example.com',
      'name': 'John',
      'surname': 'Doe',
      'profileImage': 'https://example.com/image.jpg',
      'storageUsedMb': 500,
      'storageTotalMb': 1024,
      'stats': {
        'fileCount': 100,
        'folderCount': 10,
        'deviceCount': 2,
      }
    };

    group('getUserProfile', () {
      test('should retrieve token from auth local data source', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await dataSource.getUserProfile();

        // Assert
        verify(() => mockAuthLocalDataSource.getToken()).called(1);
      });

      test('should perform GET request to correct endpoint', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await dataSource.getUserProfile();

        // Assert
        verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/profile/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
            )).called(1);
      });

      test('should include Bearer token in Authorization header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response(jsonEncode(successResponse), 200);
        });

        // Act
        await dataSource.getUserProfile();

        // Assert
        expect(capturedHeaders!['Authorization'], 'Bearer $testToken');
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response(jsonEncode(successResponse), 200);
        });

        // Act
        await dataSource.getUserProfile();

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should return UserProfileModel on successful request (200)',
          () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        final result = await dataSource.getUserProfile();

        // Assert
        expect(result.id, '1');
        expect(result.email, 'test@example.com');
        expect(result.name, 'John');
        expect(result.surname, 'Doe');
        expect(result.storageUsedMb, 500);
        expect(result.fileCount, 100);
      });

      test('should parse JSON response correctly', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        final result = await dataSource.getUserProfile();

        // Assert
        expect(result.profileImage, 'https://example.com/image.jpg');
        expect(result.storageTotalMb, 1024);
        expect(result.folderCount, 10);
        expect(result.deviceCount, 2);
      });

      test('should throw exception with specific message on 401 Unauthorized',
          () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString().contains('Invalid or expired token')),
          ),
        );
      });

      test('should throw exception on 404 Not Found', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Not Found', 404),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString()
                    .contains('Error when trying to get the user profile')),
          ),
        );
      });

      test('should throw exception on server error (500)', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString()
                    .contains('Error when trying to get the user profile')),
          ),
        );
      });

      test('should throw exception on 503 Service Unavailable', () async {
        // Arrange
        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Service Unavailable', 503),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is Exception &&
                e.toString()
                    .contains('Error when trying to get the user profile')),
          ),
        );
      });

      test('should handle profile without optional fields', () async {
        // Arrange
        final minimalResponse = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'John',
          'storageUsedMb': 500,
          'storageTotalMb': 1024,
          'stats': {
            'fileCount': 100,
            'folderCount': 10,
            'deviceCount': 2,
          }
        };

        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(minimalResponse), 200),
        );

        // Act
        final result = await dataSource.getUserProfile();

        // Assert
        expect(result.id, '1');
        expect(result.surname, isNull);
        expect(result.profileImage, isNull);
      });

      test('should handle missing stats in response', () async {
        // Arrange
        final responseWithoutStats = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'John',
          'storageUsedMb': 500,
          'storageTotalMb': 1024,
        };

        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseWithoutStats), 200),
        );

        // Act
        final result = await dataSource.getUserProfile();

        // Assert
        expect(result.fileCount, 0);
        expect(result.folderCount, 0);
        expect(result.deviceCount, 0);
      });
    });

    group('custom base URL', () {
      test('should use custom baseUrl when provided', () async {
        // Arrange
        const customBaseUrl = 'https://api.example.com';
        final customDataSource = ProfileRemoteDataSourceImpl(
          client: mockHttpClient,
          authLocalDataSource: mockAuthLocalDataSource,
          baseUrl: customBaseUrl,
        );

        when(() => mockAuthLocalDataSource.getToken())
            .thenAnswer((_) async => testToken);
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await customDataSource.getUserProfile();

        // Assert
        verify(() => mockHttpClient.get(
              Uri.parse('$customBaseUrl/api/profile/'),
              headers: any(named: 'headers'),
            )).called(1);
      });
    });
  });
}
