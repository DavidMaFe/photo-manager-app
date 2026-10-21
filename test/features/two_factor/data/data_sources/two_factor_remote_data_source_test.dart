import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/two_factor/data/data_sources/two_factor_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late TwoFactorRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://10.0.2.2:8080';
  final codes = List.generate(10, (i) => 'abcd$i-efgh$i');

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = TwoFactorRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  void stubPost(Object? body, {int status = 200}) {
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => http.Response(body == null ? '' : jsonEncode(body), status));
  }

  ({Uri uri, Object? body}) capturedPost() {
    final captured = verify(() => client.post(captureAny(), headers: any(named: 'headers'),
        body: captureAny(named: 'body'))).captured;
    final body = captured[1] as String?;
    return (uri: captured[0] as Uri, body: body == null ? null : jsonDecode(body));
  }

  group('TwoFactorRemoteDataSource', () {
    test('should GET the status', () async {
      when(() => client.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response(jsonEncode({'totpEnabled': true, 'backupCodesLeft': 7}), 200));

      final status = await dataSource.getStatus();

      final uri = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
      expect(uri.toString(), '$baseUrl/api/auth/2fa/');
      expect(status.totpEnabled, isTrue);
      expect(status.backupCodesLeft, 7);
    });

    test('should POST the set-up without a body and parse the secret', () async {
      stubPost({'secret': 'GEZDGNBV', 'otpauthUri': 'otpauth://totp/x'});

      final setUp = await dataSource.setUpTotp();

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/2fa/totp/setup/');
      expect(request.body, isNull);
      expect(setUp.secret, 'GEZDGNBV');
      expect(setUp.otpauthUri, 'otpauth://totp/x');
    });

    test('should send the code to turn the app on and parse the backup codes', () async {
      stubPost({'backupCodes': codes});

      final result = await dataSource.enableTotp('123456');

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/2fa/totp/enable/');
      expect(request.body, {'code': '123456'});
      expect(result, codes);
    });

    test('should send the authKey and the code to turn the app off', () async {
      stubPost(null, status: 204);

      await dataSource.disableTotp('YXV0aEtleQ==', 'abcde-fghjk');

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/2fa/totp/disable/');
      expect(request.body, {'authKey': 'YXV0aEtleQ==', 'code': 'abcde-fghjk'});
    });

    test('should send the authKey and the code for new backup codes', () async {
      stubPost({'backupCodes': codes});

      final result = await dataSource.regenerateBackupCodes('YXV0aEtleQ==', '123456');

      final request = capturedPost();
      expect(request.uri.toString(), '$baseUrl/api/auth/2fa/backup-codes/');
      expect(request.body, {'authKey': 'YXV0aEtleQ==', 'code': '123456'});
      expect(result, codes);
    });

    test('should throw ApiException with the backend error', () async {
      stubPost({'code': 'INVALID_TOTP_CODE', 'message': 'The code is not valid', 'timestamp': 'now'}, status: 400);

      expect(() => dataSource.enableTotp('000000'),
          throwsA(isA<ApiException>().having((e) => e.code, 'code', 'INVALID_TOTP_CODE')));
    });

    test('should rethrow socket errors', () async {
      when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
          .thenThrow(const SocketException('offline'));

      expect(() => dataSource.setUpTotp(), throwsA(isA<SocketException>()));
    });
  });
}
