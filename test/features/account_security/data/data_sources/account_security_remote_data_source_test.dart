import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/crypto/domain/key_material.dart';
import 'package:photo_manager_app/core/crypto/domain/key_version.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/account_security/data/data_sources/account_security_remote_data_source.dart';

import '../../../../fixtures/e2ee_test_data.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late AccountSecurityRemoteDataSourceImpl dataSource;
  late MockHttpClient client;
  const baseUrl = 'http://10.0.2.2:8080';
  final kdfJson = E2eeTestData.kdfParamsJson(seed: 3);

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = AccountSecurityRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  void stubPost(Object? body, {int status = 200}) {
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(body == null ? '' : jsonEncode(body), status));
  }

  ({Uri uri, Map<String, dynamic> body}) capturedPost() {
    final captured = verify(() => client.post(captureAny(), headers: any(named: 'headers'),
        body: captureAny(named: 'body'))).captured;
    return (uri: captured[0] as Uri, body: jsonDecode(captured[1] as String) as Map<String, dynamic>);
  }

  group('AccountSecurityRemoteDataSource', () {
    test('should GET the kdf parameters of the email', () async {
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode(kdfJson), 200));

      final params = await dataSource.getKdfParams('test@example.com');

      final uri = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
      expect(uri.path, '/api/auth/kdf-params/');
      expect(uri.queryParameters, {'email': 'test@example.com'});
      expect(params.salt, E2eeTestData.bytes(16, 3));
    });

    test('should GET the key versions of the account', () async {
      when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
          jsonEncode(E2eeTestData.accountKeysJson(accountLocked: true, keys: [
            E2eeTestData.keyVersionJson(version: 1, state: 'LOCKED'),
            E2eeTestData.keyVersionJson(version: 2, state: 'UNLOCKED'),
          ])),
          200));

      final keys = await dataSource.getAccountKeys();

      final uri = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
      expect(uri.toString(), '$baseUrl/api/auth/keys/');
      expect(keys.accountLocked, isTrue);
      expect(keys.versions.map((version) => version.state), [KeyState.locked, KeyState.unlocked]);
    });

    test('should POST the password change with both authKeys, the new salt and the rewrapped keys', () async {
      stubPost(null);

      await dataSource.changePassword(
        currentAuthKey: 'Y3VycmVudA==',
        newAuthKey: 'bmV3',
        kdfParams: E2eeTestData.kdfParams(seed: 3),
        keys: [RewrappedKey(version: 2, encryptedMasterKey: E2eeTestData.bytes(72, 9))],
      );

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/password-change/');
      expect(request.body, {
        'currentAuthKey': 'Y3VycmVudA==',
        'newAuthKey': 'bmV3',
        'kdfSalt': kdfJson['kdfSalt'],
        'kdfParams': {'algorithm': 'argon2id13', 'ops': 2, 'memBytes': 32 * 1024 * 1024},
        'keys': [
          {'version': 2, 'encryptedMasterKey': base64Encode(E2eeTestData.bytes(72, 9))},
        ],
      });
    });

    test('should POST the device reset with the proof of each key', () async {
      stubPost(null);

      await dataSource.resetPasswordFromDevice(
        newAuthKey: 'bmV3',
        kdfParams: E2eeTestData.kdfParams(seed: 3),
        keys: [DeviceRewrappedKey(version: 1, masterKeyAuth: E2eeTestData.bytes(32, 5),
            encryptedMasterKey: E2eeTestData.bytes(72, 9))],
      );

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/password-reset/device/');
      expect(request.body['newAuthKey'], 'bmV3');
      expect(request.body['kdfSalt'], kdfJson['kdfSalt']);
      expect(request.body['keys'], [
        {
          'version': 1,
          'masterKeyAuth': base64Encode(E2eeTestData.bytes(32, 5)),
          'encryptedMasterKey': base64Encode(E2eeTestData.bytes(72, 9)),
        },
      ]);
    });

    test('should POST a new key and return its version', () async {
      stubPost({'version': 3}, status: 201);
      final material = E2eeTestData.newKeyMaterial();

      final version = await dataSource.createKeyVersion(material);

      final request = capturedPost();
      expect(version, 3);
      expect(request.uri.toString(), '$baseUrl/api/auth/keys/');
      expect(request.body['encryptedMasterKey'], base64Encode(material.encryptedMasterKey));
      expect(request.body['recoveryAuthKey'], base64Encode(material.recoveryAuthKey));
      expect(request.body.containsKey('masterKey'), isFalse);
      expect(request.body.containsKey('recoveryKey'), isFalse);
    });

    test('should POST an unlock with only the proof given', () async {
      stubPost(null);

      await dataSource.unlockKeyVersion(version: 1, recoveryAuthKey: 'cHJvb2Y=', encryptedMasterKey: 'a2V5');

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/keys/1/unlock/');
      expect(request.body, {'recoveryAuthKey': 'cHJvb2Y=', 'encryptedMasterKey': 'a2V5'});
    });

    test('should throw ApiException with the error of the backend', () async {
      stubPost({'code': 'INVALID_KEY_PROOF', 'message': 'The proof does not match', 'timestamp': 'now'}, status: 403);

      await expectLater(
        dataSource.unlockKeyVersion(version: 1, masterKeyAuth: 'cHJvb2Y=', encryptedMasterKey: 'a2V5'),
        throwsA(isA<ApiException>().having((e) => e.errorResponse.code, 'code', 'INVALID_KEY_PROOF')),
      );
    });

    test('should wrap connection errors', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(StateError('closed'));

      await expectLater(dataSource.createKeyVersion(E2eeTestData.newKeyMaterial()), throwsException);
    });
  });
}
