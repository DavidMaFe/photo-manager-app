import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(client: mockHttpClient);
  });

  group('AuthRemoteDataSource', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testToken = 'test_token_123';
    const baseUrl = 'http://10.0.2.2:8080';

    group('login', () {
      final successResponse = {
        'token': testToken,
        'id': '1',
        'email': testEmail,
        'name': 'John',
        'surname': 'Doe',
      };

      test('should perform POST request to correct endpoint', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await dataSource.login(testEmail, testPassword);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/login/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({'email': testEmail, 'password': testPassword}),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should return AuthResponseModel on successful login (200)',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        final result = await dataSource.login(testEmail, testPassword);

        // Assert
        expect(result.token, testToken);
        expect(result.user.id, '1');
        expect(result.user.email, testEmail);
        expect(result.user.name, 'John');
      });

      test('should send correct JSON body in request', () async {
        // Arrange
        String? capturedBody;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedBody = invocation.namedArguments[#body] as String;
          return http.Response(jsonEncode(successResponse), 200);
        });

        // Act
        await dataSource.login(testEmail, testPassword);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
        expect(decodedBody['password'], testPassword);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response(jsonEncode(successResponse), 200);
        });

        // Act
        await dataSource.login(testEmail, testPassword);

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should throw ApiException on non-200 response', () async {
        // Arrange
        final errorResponse = {
          'code': 'INVALID_CREDENTIALS',
          'message': 'Invalid email or password',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/login/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 401),
        );

        // Act & Assert
        expect(
          () => dataSource.login(testEmail, testPassword),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INVALID_CREDENTIALS' &&
                e.message == 'Invalid email or password'),
          ),
        );
      });

      test('should wrap network errors in connection error exception',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow('Network error');

        // Act & Assert
        expect(
          () => dataSource.login(testEmail, testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should parse valid JSON response correctly', () async {
        // Arrange
        final responseWithAllFields = {
          'token': testToken,
          'id': '123',
          'email': 'user@test.com',
          'name': 'Jane',
          'surname': 'Smith',
          'refreshToken': 'refresh_token_456',
        };

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(responseWithAllFields), 200),
        );

        // Act
        final result = await dataSource.login(testEmail, testPassword);

        // Assert
        expect(result.token, testToken);
        expect(result.user.id, '123');
        expect(result.user.email, 'user@test.com');
        expect(result.user.name, 'Jane');
        expect(result.user.surname, 'Smith');
        expect(result.refreshToken, 'refresh_token_456');
      });

      test('should wrap Exception types in connection error', () async {
        // Arrange
        final testException = Exception('Custom error');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.login(testEmail, testPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });
    });

    group('logout', () {
      test('should perform POST request to logout endpoint', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('', 200),
        );

        // Act
        await dataSource.logout(testToken);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/logout/'),
              headers: captureAny(named: 'headers'),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers['Authorization'], 'Bearer $testToken');
        expect(headers.containsKey('Accept-Language'), true);
      });

      test('should include Bearer token in Authorization header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response('', 200);
        });

        // Act
        await dataSource.logout(testToken);

        // Assert
        expect(capturedHeaders!['Authorization'], 'Bearer $testToken');
      });

      test('should complete successfully on 200 response', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Success', 200),
        );

        // Act & Assert - should not throw
        await expectLater(dataSource.logout(testToken), completes);
      });

      test('should silently ignore errors (no exception thrown)', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow(Exception('Network error'));

        // Act & Assert - should not throw
        await expectLater(dataSource.logout(testToken), completes);
      });

      test('should silently ignore 401 Unauthorized errors', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Unauthorized', 401),
        );

        // Act & Assert - should not throw
        await expectLater(dataSource.logout(testToken), completes);
      });

      test('should silently ignore server errors (500)', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenAnswer(
          (_) async => http.Response('Internal Server Error', 500),
        );

        // Act & Assert - should not throw
        await expectLater(dataSource.logout(testToken), completes);
      });

      test('should silently ignore network connection errors', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
            )).thenThrow('Connection refused');

        // Act & Assert - should not throw
        await expectLater(dataSource.logout(testToken), completes);
      });
    });

    group('requestPasswordReset', () {
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
        await dataSource.requestPasswordReset(testEmail);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/request/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({'email': testEmail}),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
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

        // Act & Assert - should not throw
        await expectLater(dataSource.requestPasswordReset(testEmail), completes);
      });

      test('should send correct JSON body in request', () async {
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
        await dataSource.requestPasswordReset(testEmail);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response('', 200);
        });

        // Act
        await dataSource.requestPasswordReset(testEmail);

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should throw ApiException with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {
          'code': 'EMAIL_NOT_FOUND',
          'message': 'Email not found',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/password-reset/request/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 404),
        );

        // Act & Assert
        expect(
          () => dataSource.requestPasswordReset(testEmail),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'EMAIL_NOT_FOUND' &&
                e.message == 'Email not found'),
          ),
        );
      });

      test('should wrap network errors in connection error exception',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow('Network error');

        // Act & Assert
        expect(
          () => dataSource.requestPasswordReset(testEmail),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should wrap Exception types in connection error', () async {
        // Arrange
        final testException = Exception('Custom error');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.requestPasswordReset(testEmail),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });
    });

    group('validateResetCode', () {
      const testCode = '123456';

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
        await dataSource.validateResetCode(testEmail, testCode);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/validate/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({'email': testEmail, 'code': testCode}),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
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

        // Act & Assert - should not throw
        await expectLater(
            dataSource.validateResetCode(testEmail, testCode), completes);
      });

      test('should send correct JSON body in request', () async {
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
        await dataSource.validateResetCode(testEmail, testCode);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
        expect(decodedBody['code'], testCode);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response('', 200);
        });

        // Act
        await dataSource.validateResetCode(testEmail, testCode);

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should throw ApiException with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {
          'code': 'INVALID_CODE',
          'message': 'Invalid or expired code',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/password-reset/validate/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 400),
        );

        // Act & Assert
        expect(
          () => dataSource.validateResetCode(testEmail, testCode),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INVALID_CODE' &&
                e.message == 'Invalid or expired code'),
          ),
        );
      });

      test('should wrap network errors in connection error exception',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow('Network error');

        // Act & Assert
        expect(
          () => dataSource.validateResetCode(testEmail, testCode),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should wrap Exception types in connection error', () async {
        // Arrange
        final testException = Exception('Custom error');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.validateResetCode(testEmail, testCode),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });
    });

    group('resetPassword', () {
      const testCode = '123456';
      const testNewPassword = 'newPassword123';

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
        await dataSource.resetPassword(testEmail, testCode, testNewPassword);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/reset/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({
                'email': testEmail,
                'code': testCode,
                'newPassword': testNewPassword
              }),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
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

        // Act & Assert - should not throw
        await expectLater(
            dataSource.resetPassword(testEmail, testCode, testNewPassword),
            completes);
      });

      test('should send correct JSON body in request', () async {
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
        await dataSource.resetPassword(testEmail, testCode, testNewPassword);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
        expect(decodedBody['code'], testCode);
        expect(decodedBody['newPassword'], testNewPassword);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response('', 200);
        });

        // Act
        await dataSource.resetPassword(testEmail, testCode, testNewPassword);

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should throw ApiException with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {
          'code': 'CODE_EXPIRED',
          'message': 'Reset code has expired',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/password-reset/reset/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 400),
        );

        // Act & Assert
        expect(
          () => dataSource.resetPassword(testEmail, testCode, testNewPassword),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'CODE_EXPIRED' &&
                e.message == 'Reset code has expired'),
          ),
        );
      });

      test('should wrap network errors in connection error exception',
          () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow('Network error');

        // Act & Assert
        expect(
          () => dataSource.resetPassword(testEmail, testCode, testNewPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should wrap Exception types in connection error', () async {
        // Arrange
        final testException = Exception('Custom error');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.resetPassword(testEmail, testCode, testNewPassword),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });
    });

    group('register', () {
      const testName = 'John';
      const testSurname = 'Doe';

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
        await dataSource.register(testEmail, testPassword, testName, testSurname);

        // Assert
        final captured = verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/register/'),
              headers: captureAny(named: 'headers'),
              body: jsonEncode({
                'email': testEmail,
                'password': testPassword,
                'name': testName,
                'surname': testSurname,
              }),
            ));
        captured.called(1);

        final headers = captured.captured.last as Map<String, String>;
        expect(headers['Content-Type'], 'application/json');
        expect(headers.containsKey('Accept-Language'), true);
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

        // Act & Assert - should not throw
        await expectLater(
            dataSource.register(testEmail, testPassword, testName, testSurname),
            completes);
      });

      test('should send correct JSON body in request with surname', () async {
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
        await dataSource.register(testEmail, testPassword, testName, testSurname);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
        expect(decodedBody['password'], testPassword);
        expect(decodedBody['name'], testName);
        expect(decodedBody['surname'], testSurname);
      });

      test('should send correct JSON body in request without surname', () async {
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
        await dataSource.register(testEmail, testPassword, testName, null);

        // Assert
        final decodedBody = jsonDecode(capturedBody!);
        expect(decodedBody['email'], testEmail);
        expect(decodedBody['password'], testPassword);
        expect(decodedBody['name'], testName);
        expect(decodedBody.containsKey('surname'), isFalse);
      });

      test('should set correct Content-Type header', () async {
        // Arrange
        Map<String, String>? capturedHeaders;
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer((invocation) async {
          capturedHeaders =
              invocation.namedArguments[#headers] as Map<String, String>;
          return http.Response('', 200);
        });

        // Act
        await dataSource.register(testEmail, testPassword, testName, testSurname);

        // Assert
        expect(capturedHeaders!['Content-Type'], 'application/json');
      });

      test('should throw ApiException with error message on non-200 response',
          () async {
        // Arrange
        final errorResponse = {
          'code': 'EMAIL_ALREADY_USED',
          'message': 'Email already registered',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/register/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 400),
        );

        // Act & Assert
        expect(
          () => dataSource.register(testEmail, testPassword, testName, testSurname),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'EMAIL_ALREADY_USED' &&
                e.message == 'Email already registered'),
          ),
        );
      });

      test('should throw ApiException on 500 server error', () async {
        // Arrange
        final errorResponse = {
          'code': 'INTERNAL_SERVER_ERROR',
          'message': 'Internal server error',
          'timestamp': '2025-01-26T10:30:45.123456',
          'path': '/api/register/',
        };
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(errorResponse), 500),
        );

        // Act & Assert
        expect(
          () => dataSource.register(testEmail, testPassword, testName, testSurname),
          throwsA(
            predicate((e) =>
                e is ApiException &&
                e.code == 'INTERNAL_SERVER_ERROR' &&
                e.message == 'Internal server error'),
          ),
        );
      });

      test('should wrap network errors in connection error exception', () async {
        // Arrange
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow('Network error');

        // Act & Assert
        expect(
          () => dataSource.register(testEmail, testPassword, testName, testSurname),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should wrap Exception types in connection error', () async {
        // Arrange
        final testException = Exception('Custom error');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.register(testEmail, testPassword, testName, testSurname),
          throwsA(
            predicate((e) =>
                e is Exception && e.toString().contains('Connection error')),
          ),
        );
      });

      test('should rethrow HttpException types directly', () async {
        // Arrange
        const testException = HttpException('Email already exists');
        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenThrow(testException);

        // Act & Assert
        expect(
          () => dataSource.register(testEmail, testPassword, testName, testSurname),
          throwsA(testException),
        );
      });
    });

    group('custom base URL', () {
      test('should use custom baseUrl when provided', () async {
        // Arrange
        const customBaseUrl = 'https://api.example.com';
        final customDataSource = AuthRemoteDataSourceImpl(
          client: mockHttpClient,
          baseUrl: customBaseUrl,
        );

        final successResponse = {
          'token': testToken,
          'id': '1',
          'email': testEmail,
          'name': 'John',
          'surname': 'Doe',
        };

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response(jsonEncode(successResponse), 200),
        );

        // Act
        await customDataSource.login(testEmail, testPassword);

        // Assert
        verify(() => mockHttpClient.post(
              Uri.parse('$customBaseUrl/api/login/'),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).called(1);
      });

      test('should use custom baseUrl for register endpoint', () async {
        // Arrange
        const customBaseUrl = 'https://api.example.com';
        final customDataSource = AuthRemoteDataSourceImpl(
          client: mockHttpClient,
          baseUrl: customBaseUrl,
        );

        when(() => mockHttpClient.post(
              any(),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).thenAnswer(
          (_) async => http.Response('', 200),
        );

        // Act
        await customDataSource.register(testEmail, testPassword, 'John', 'Doe');

        // Assert
        verify(() => mockHttpClient.post(
              Uri.parse('$customBaseUrl/api/register/'),
              headers: any(named: 'headers'),
              body: any(named: 'body'),
            )).called(1);
      });
    });
  });
}
