import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_remote_data_source.dart';

import '../../../../fixtures/e2ee_test_data.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;
  const baseUrl = 'http://10.0.2.2:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = AuthRemoteDataSourceImpl(client: mockHttpClient, baseUrl: baseUrl);
  });

  void stubPost(Object? body, {int status = 200}) {
    when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(body == null ? '' : jsonEncode(body), status));
  }

  ({Uri uri, Map<String, dynamic> body}) capturedPost() {
    final captured = verify(() => mockHttpClient.post(captureAny(), headers: any(named: 'headers'),
        body: captureAny(named: 'body'))).captured;
    return (uri: captured[0] as Uri, body: jsonDecode(captured[1] as String) as Map<String, dynamic>);
  }

  final errorBody = {'code': 'INVALID_RECOVERY_KEY', 'message': 'The recovery key does not match', 'timestamp': 'now'};

  group('AuthRemoteDataSource', () {
    group('getKdfParams', () {
      test('should GET the public kdf-params endpoint with the email and parse the parameters', () async {
        // Arrange
        when(() => mockHttpClient.get(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response(jsonEncode(E2eeTestData.kdfParamsJson()), 200));

        // Act
        final params = await dataSource.getKdfParams('test@example.com');

        // Assert
        final uri = verify(() => mockHttpClient.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
        expect(uri.path, '/api/auth/kdf-params/');
        expect(uri.queryParameters['email'], 'test@example.com');
        expect(params.salt, E2eeTestData.bytes(16, 1));
        expect(params.ops, 2);
        expect(params.memBytes, 32 * 1024 * 1024);
      });
    });

    group('login', () {
      test('should send the authKey (never a password) and parse tokens and keys', () async {
        // Arrange
        stubPost(E2eeTestData.authResponseJson());

        // Act
        final response = await dataSource.login('test@example.com', 'YXV0aEtleQ==', 'uuid_123');

        // Assert
        final request = capturedPost();
        expect(request.uri.toString(), '$baseUrl/api/login/');
        expect(request.body, {'email': 'test@example.com', 'authKey': 'YXV0aEtleQ==', 'deviceUuid': 'uuid_123'});
        expect(request.body.containsKey('password'), isFalse);
        expect(response.token, 'access_token');
        expect(response.refreshToken, 'refresh_token');
        expect(response.keys!.accountLocked, isFalse);
        expect(response.keys!.versions.single.state, KeyState.current);
        expect(response.keys!.versions.single.encryptedMasterKey, E2eeTestData.bytes(72, 1));
      });

      test('should parse a locked account', () async {
        stubPost(E2eeTestData.authResponseJson(accountLocked: true));

        final response = await dataSource.login('test@example.com', 'a', 'uuid');

        expect(response.keys!.accountLocked, isTrue);
        expect(response.keys!.versions.single.state, KeyState.locked);
      });

      test('should throw ApiException with the backend error on a non-2xx response', () async {
        stubPost({'code': 'INVALID_CREDENTIALS', 'message': 'Bad credentials', 'timestamp': 'now'}, status: 401);

        expect(() => dataSource.login('test@example.com', 'a', 'uuid'), throwsA(isA<ApiException>()));
      });

      test('should rethrow socket errors and wrap other errors', () async {
        when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
            .thenThrow(const SocketException('offline'));
        expect(() => dataSource.login('e', 'a', 'u'), throwsA(isA<SocketException>()));

        when(() => mockHttpClient.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
            .thenThrow(StateError('boom'));
        expect(() => dataSource.login('e', 'a', 'u'),
            throwsA(isA<Exception>().having((e) => e.toString(), 'message', contains('Connection error'))));
      });
    });

    group('register', () {
      test('should send the authKey, the KDF parameters and the wrapped key material', () async {
        // Arrange
        stubPost(E2eeTestData.authResponseJson());
        final key = E2eeTestData.newKeyMaterial();

        // Act
        await dataSource.register(
          email: 'test@example.com',
          authKey: 'YXV0aEtleQ==',
          name: 'John',
          surname: null,
          deviceUuid: 'uuid_123',
          kdfParams: E2eeTestData.kdfParams(),
          key: key,
        );

        // Assert
        final body = capturedPost().body;
        expect(body['authKey'], 'YXV0aEtleQ==');
        expect(body.containsKey('surname'), isFalse);
        expect(body['kdfSalt'], base64Encode(E2eeTestData.bytes(16, 1)));
        expect(body['kdfParams'], {'algorithm': 'argon2id13', 'ops': 2, 'memBytes': 32 * 1024 * 1024});
        final sentKey = body['key'] as Map<String, dynamic>;
        expect(sentKey['encryptedMasterKey'], base64Encode(key.encryptedMasterKey));
        expect(sentKey['recoveryAuthKey'], base64Encode(key.recoveryAuthKey));
        expect(sentKey['masterKeyAuth'], base64Encode(key.masterKeyAuth));
        // The master key and the recovery key themselves never leave the device
        expect(jsonEncode(body).contains(base64Encode(key.masterKey.bytes)), isFalse);
        expect(jsonEncode(body).contains(base64Encode(key.recoveryKey.bytes)), isFalse);
      });

      test('should include the surname when there is one', () async {
        stubPost(E2eeTestData.authResponseJson());

        await dataSource.register(email: 'e@example.com', authKey: 'a', name: 'John', surname: 'Doe',
            deviceUuid: 'u', kdfParams: E2eeTestData.kdfParams(), key: E2eeTestData.newKeyMaterial());

        expect(capturedPost().body['surname'], 'Doe');
      });
    });

    group('password reset', () {
      test('should request and validate the emailed code', () async {
        stubPost(null);

        await dataSource.requestPasswordReset('test@example.com');
        expect(capturedPost().uri.path, '/api/password-reset/request/');

        await dataSource.validateResetCode('test@example.com', '123456');
        final request = capturedPost();
        expect(request.uri.path, '/api/password-reset/validate/');
        expect(request.body, {'email': 'test@example.com', 'code': '123456'});
      });

      test('should get the recovery wraps with the emailed code', () async {
        stubPost({
          'keys': [
            {'version': 1, 'state': 'LOCKED', 'masterKeyByRecovery': base64Encode(E2eeTestData.bytes(72, 9))},
          ],
        });

        final wraps = await dataSource.getRecoveryWraps('test@example.com', '123456');

        expect(capturedPost().uri.path, '/api/password-reset/recovery-keys/');
        expect(wraps.single.version, 1);
        expect(wraps.single.masterKeyByRecovery, E2eeTestData.bytes(72, 9));
      });

      test('should reset with the new authKey and the recovered keys, and return accountLocked', () async {
        stubPost({'accountLocked': false});
        final recovered = RecoveredKey(version: 1, recoveryAuthKey: E2eeTestData.bytes(32, 3),
            encryptedMasterKey: E2eeTestData.bytes(72, 4), masterKey: E2eeTestData.key(5));

        final accountLocked = await dataSource.resetPassword(email: 'test@example.com', code: '123456',
            newAuthKey: 'bmV3', kdfParams: E2eeTestData.kdfParams(), recoveredKeys: [recovered]);

        final body = capturedPost().body;
        expect(accountLocked, isFalse);
        expect(body['newAuthKey'], 'bmV3');
        expect(body.containsKey('newPassword'), isFalse);
        expect(body['recoveredKeys'], [
          {'version': 1, 'recoveryAuthKey': base64Encode(E2eeTestData.bytes(32, 3)),
            'encryptedMasterKey': base64Encode(E2eeTestData.bytes(72, 4))},
        ]);
      });

      test('should send an empty list without the 24 words and report the locked account', () async {
        stubPost({'accountLocked': true});

        final accountLocked = await dataSource.resetPassword(email: 'e@example.com', code: '123456',
            newAuthKey: 'bmV3', kdfParams: E2eeTestData.kdfParams(), recoveredKeys: const []);

        expect(accountLocked, isTrue);
        expect(capturedPost().body['recoveredKeys'], isEmpty);
      });

      test('should throw ApiException when the recovery key is wrong', () async {
        stubPost(errorBody, status: 400);

        expect(() => dataSource.resetPassword(email: 'e@example.com', code: '1', newAuthKey: 'a',
            kdfParams: E2eeTestData.kdfParams(), recoveredKeys: const []), throwsA(isA<ApiException>()));
      });
    });

    group('refreshToken', () {
      test('should POST the refresh token and the device', () async {
        stubPost({'accessToken': 'new_access', 'refreshToken': 'new_refresh'});

        final response = await dataSource.refreshToken('refresh_token', 'uuid_123');

        final request = capturedPost();
        expect(request.uri.path, '/api/auth/refresh/');
        expect(request.body, {'refreshToken': 'refresh_token', 'deviceUuid': 'uuid_123'});
        expect(response.accessToken, 'new_access');
      });
    });

    group('logout', () {
      test('should POST with the bearer token', () async {
        when(() => mockHttpClient.post(any(), headers: any(named: 'headers')))
            .thenAnswer((_) async => http.Response('', 200));

        await dataSource.logout('token_123');

        final headers = verify(() => mockHttpClient.post(any(), headers: captureAny(named: 'headers')))
            .captured.single as Map<String, String>;
        expect(headers['Authorization'], 'Bearer token_123');
      });

      test('should silently ignore errors (the local session is cleared anyway)', () async {
        when(() => mockHttpClient.post(any(), headers: any(named: 'headers')))
            .thenThrow(const SocketException('offline'));

        await expectLater(dataSource.logout('token_123'), completes);
      });
    });
  });
}
