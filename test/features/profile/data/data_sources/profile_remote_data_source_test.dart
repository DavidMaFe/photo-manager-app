import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/profile/data/data_sources/profile_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

class FakeRequest extends Fake implements http.Request {}

void main() {
  late ProfileRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
    registerFallbackValue(FakeRequest());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = ProfileRemoteDataSourceImpl(
      client: mockHttpClient,
      baseUrl: 'http://10.0.2.2:8080',
    );
  });

  group('ProfileRemoteDataSource', () {
    const baseUrl = 'http://10.0.2.2:8080';

    final successResponse = {
      'id': '1',
      'email': 'test@example.com',
      'name': 'John',
      'surname': 'Doe',
      'hasProfileImage': true,
      'storageUsedMb': 500,
      'storageTotalMb': 1024,
      'stats': {
        'fileCount': 100,
        'folderCount': 10,
        'deviceCount': 2,
      }
    };

    group('getUserProfile', () {
      test('should perform GET request to correct endpoint', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await dataSource.getUserProfile();

        // Assert
        final captured = verify(() => mockHttpClient.get(
              Uri.parse('$baseUrl/api/profile/'),
              headers: captureAny(named: 'headers'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
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
        expect(capturedHeaders!.containsKey('Accept-Language'), true);
      });

      test('should return UserProfileModel on successful request (200)',
          () async {
        // Arrange
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
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        final result = await dataSource.getUserProfile();

        // Assert
        expect(result.hasProfileImage, true);
        expect(result.storageTotalMb, 1024);
        expect(result.folderCount, 10);
        expect(result.deviceCount, 2);
      });

      test('should throw ApiException on 401 Unauthorized', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'UNAUTHORIZED',
              'message': 'Invalid or expired token',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            401,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'UNAUTHORIZED' &&
                e.message == 'Invalid or expired token'),
          ),
        );
      });

      test('should throw ApiException on 404 Not Found', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'PROFILE_NOT_FOUND',
              'message': 'User profile not found',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            404,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'PROFILE_NOT_FOUND' &&
                e.message == 'User profile not found'),
          ),
        );
      });

      test('should throw ApiException on server error (500)', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Internal server error',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            500,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INTERNAL_SERVER_ERROR' &&
                e.message == 'Internal server error'),
          ),
        );
      });

      test('should throw ApiException on 503 Service Unavailable', () async {
        // Arrange
        when(() => mockHttpClient.get(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'SERVICE_UNAVAILABLE',
              'message': 'Service temporarily unavailable',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            503,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.getUserProfile(),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'SERVICE_UNAVAILABLE' &&
                e.message == 'Service temporarily unavailable'),
          ),
        );
      });

      test('should handle profile without optional fields', () async {
        // Arrange
        final minimalResponse = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'John',
          'hasProfileImage': false,
          'storageUsedMb': 500,
          'storageTotalMb': 1024,
          'stats': {
            'fileCount': 100,
            'folderCount': 10,
            'deviceCount': 2,
          }
        };

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
      });

      test('should handle missing stats in response', () async {
        // Arrange
        final responseWithoutStats = {
          'id': '1',
          'email': 'test@example.com',
          'name': 'John',
          'hasProfileImage': false,
          'storageUsedMb': 500,
          'storageTotalMb': 1024,
        };

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
          baseUrl: customBaseUrl,
        );

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

    group('updateUserProfile', () {
      final updatedProfileResponse = {
        'id': '1',
        'email': 'test@example.com',
        'name': 'Jane',
        'surname': 'Smith',
        'hasProfileImage': true,
        'storageUsedMb': 500,
        'storageTotalMb': 1024,
        'stats': {
          'fileCount': 100,
          'folderCount': 10,
          'deviceCount': 2,
        }
      };

      test('should perform PUT request to correct endpoint', () async{
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(updatedProfileResponse), 200),
        );

        // Act
        await dataSource.updateUserProfile(name: 'Jane');

        // Assert
        final captured = verify(() => mockHttpClient.put(
              Uri.parse('$baseUrl/api/profile/'),
              headers: captureAny(named: 'headers'),
              body: any(named: 'body'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should send only name in request body when only name is provided',
          () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response(jsonEncode(updatedProfileResponse), 200);
        });

        // Act
        await dataSource.updateUserProfile(name: 'Jane');

        // Assert
        final bodyMap = jsonDecode(capturedBody!);
        expect(bodyMap['name'], 'Jane');
        expect(bodyMap.containsKey('surname'), false);
        expect(bodyMap.containsKey('profileImage'), false);
      });

      test('should send all fields in request body when all are provided',
          () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response(jsonEncode(updatedProfileResponse), 200);
        });

        // Act
        await dataSource.updateUserProfile(
          name: 'Jane',
          surname: 'Smith',
          profileImage: 'base64image',
        );

        // Assert
        final bodyMap = jsonDecode(capturedBody!);
        expect(bodyMap['name'], 'Jane');
        expect(bodyMap['surname'], 'Smith');
        expect(bodyMap['profileImage'], 'base64image');
      });

      test('should return updated UserProfileModel on successful request (200)',
          () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(updatedProfileResponse), 200),
        );

        // Act
        final result = await dataSource.updateUserProfile(
          name: 'Jane',
          surname: 'Smith',
        );

        // Assert
        expect(result.id, '1');
        expect(result.name, 'Jane');
        expect(result.surname, 'Smith');
        expect(result.email, 'test@example.com');
      });

      test('should throw ApiException on 401 Unauthorized', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'UNAUTHORIZED',
              'message': 'Invalid or expired token',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            401,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.updateUserProfile(name: 'Jane'),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'UNAUTHORIZED' &&
                e.message == 'Invalid or expired token'),
          ),
        );
      });

      test('should throw ApiException on 400 Bad Request', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'INVALID_PROFILE_DATA',
              'message': 'Invalid profile data',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            400,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.updateUserProfile(name: ''),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INVALID_PROFILE_DATA' &&
                e.message == 'Invalid profile data'),
          ),
        );
      });

      test('should throw ApiException on server error (500)', () async {
        // Arrange
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Internal server error',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/profile/',
            }),
            500,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.updateUserProfile(name: 'Jane'),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INTERNAL_SERVER_ERROR' &&
                e.message == 'Internal server error'),
          ),
        );
      });

      test('should handle profile image update only', () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.put(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response(jsonEncode(updatedProfileResponse), 200);
        });

        // Act
        await dataSource.updateUserProfile(profileImage: 'base64image');

        // Assert
        final bodyMap = jsonDecode(capturedBody!);
        expect(bodyMap['profileImage'], 'base64image');
        expect(bodyMap.containsKey('name'), false);
        expect(bodyMap.containsKey('surname'), false);
      });
    });

    group('changePassword', () {
      test('should perform POST request to correct endpoint', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response('', 200),
        );

        // Act
        await dataSource.changePassword(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
        );

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-change/'),
              headers: captureAny(named: 'headers'),
              body: any(named: 'body'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should send correct passwords in request body', () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response('', 200);
        });

        // Act
        await dataSource.changePassword(
          currentPassword: 'oldPass123',
          newPassword: 'newPass456',
        );

        // Assert
        final bodyMap = jsonDecode(capturedBody!);
        expect(bodyMap['currentPassword'], 'oldPass123');
        expect(bodyMap['newPassword'], 'newPass456');
      });

      test('should complete successfully on 200 response', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response('', 200),
        );

        // Act & Assert
        await expectLater(
          dataSource.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
          ),
          completes,
        );
      });

      test('should throw ApiException on 401 Unauthorized', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'UNAUTHORIZED',
              'message': 'Invalid or expired token',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/password-change/',
            }),
            401,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
          ),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'UNAUTHORIZED' &&
                e.message == 'Invalid or expired token'),
          ),
        );
      });

      test('should throw ApiException on 400 Bad Request (wrong password)',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'INVALID_PASSWORD',
              'message': 'Invalid current password',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/password-change/',
            }),
            400,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.changePassword(
            currentPassword: 'wrongPass',
            newPassword: 'newPass456',
          ),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INVALID_PASSWORD' &&
                e.message == 'Invalid current password'),
          ),
        );
      });

      test('should throw ApiException on server error (500)', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(
            jsonEncode({
              'code': 'INTERNAL_SERVER_ERROR',
              'message': 'Internal server error',
              'timestamp': '2025-01-26T10:30:45.123456',
              'path': '/api/password-change/',
            }),
            500,
          ),
        );

        // Act & Assert
        expect(
          () => dataSource.changePassword(
            currentPassword: 'oldPass123',
            newPassword: 'newPass456',
          ),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INTERNAL_SERVER_ERROR' &&
                e.message == 'Internal server error'),
          ),
        );
      });

      test('should handle complex password formats', () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response('', 200);
        });

        // Act
        await dataSource.changePassword(
          currentPassword: 'Complex!Pass@123',
          newPassword: 'NewComplex!Pass@456',
        );

        // Assert
        final bodyMap = jsonDecode(capturedBody!);
        expect(bodyMap['currentPassword'], 'Complex!Pass@123');
        expect(bodyMap['newPassword'], 'NewComplex!Pass@456');
      });
    });
  });
}
