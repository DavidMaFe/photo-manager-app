import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/login/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': testEmail, 'password': testPassword}),
            )).called(1);
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
                e is Exception && e.toString().contains('Connexion error')),
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

      test('should rethrow Exception types directly', () async {
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
          throwsA(testException),
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/logout/'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $testToken',
              },
            )).called(1);
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/request/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': testEmail}),
            )).called(1);
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

      test('should throw Exception with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {'code': 'EMAIL_NOT_FOUND'};
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
                e is Exception && e.toString().contains('EMAIL_NOT_FOUND')),
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
                e is Exception && e.toString().contains('Connexion error')),
          ),
        );
      });

      test('should rethrow Exception types directly', () async {
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
          throwsA(testException),
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/validate/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'email': testEmail, 'code': testCode}),
            )).called(1);
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

      test('should throw Exception with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {'code': 'INVALID_CODE'};
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
            predicate(
                (e) => e is Exception && e.toString().contains('INVALID_CODE')),
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
                e is Exception && e.toString().contains('Connexion error')),
          ),
        );
      });

      test('should rethrow Exception types directly', () async {
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
          throwsA(testException),
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/password-reset/reset/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': testEmail,
                'code': testCode,
                'newPassword': testNewPassword
              }),
            )).called(1);
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

      test('should throw Exception with error code on non-200 response',
          () async {
        // Arrange
        final errorResponse = {'code': 'CODE_EXPIRED'};
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
            predicate(
                (e) => e is Exception && e.toString().contains('CODE_EXPIRED')),
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
                e is Exception && e.toString().contains('Connexion error')),
          ),
        );
      });

      test('should rethrow Exception types directly', () async {
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
          throwsA(testException),
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
        verify(() => mockHttpClient.post(
              Uri.parse('$baseUrl/api/register/'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'email': testEmail,
                'password': testPassword,
                'name': testName,
                'surname': testSurname,
              }),
            )).called(1);
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

      test('should throw HttpException with error message on non-200 response',
          () async {
        // Arrange
        final errorResponse = {'message': 'Email already registered'};
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
                e.toString().contains('Email already registered')),
          ),
        );
      });

      test('should throw HttpException on 500 server error', () async {
        // Arrange
        final errorResponse = {'message': 'Internal server error'};
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
                e.toString().contains('Internal server error')),
          ),
        );
      });

      test('should wrap network errors with UNKNOWN_ERROR code', () async {
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
                e is Exception && e.toString().contains('UNKNOWN_ERROR')),
          ),
        );
      });

      test('should wrap Exception types with UNKNOWN_ERROR code', () async {
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
                e is Exception && e.toString().contains('UNKNOWN_ERROR')),
          ),
        );
      });

      test('should rethrow HttpException types directly', () async {
        // Arrange
        final testException = HttpException('Email already exists');
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
