import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/exceptions/api_exception.dart';
import 'package:photo_manager_app/features/account_deletion/data/data_sources/account_deletion_remote_data_source.dart';

class MockHttpClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  late MockHttpClient client;
  late AccountDeletionRemoteDataSourceImpl dataSource;
  const baseUrl = 'http://10.0.2.2:8080';

  setUpAll(() => registerFallbackValue(FakeUri()));

  setUp(() {
    client = MockHttpClient();
    dataSource = AccountDeletionRemoteDataSourceImpl(client: client, baseUrl: baseUrl);
  });

  void stubPost(http.Response response) {
    when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
        .thenAnswer((_) async => response);
  }

  group('AccountDeletionRemoteDataSource', () {
    group('getSummary', () {
      test('should GET the deletion summary of the account', () async {
        when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async =>
            http.Response(jsonEncode({'files': 5, 'storedBytes': 2048, 'albums': 2, 'devices': 1}), 200));

        final summary = await dataSource.getSummary();

        final uri = verify(() => client.get(captureAny(), headers: any(named: 'headers'))).captured.single as Uri;
        expect(uri.toString(), '$baseUrl/api/profile/deletion-summary/');
        expect(summary.files, 5);
        expect(summary.storedBytes, 2048);
      });

      test('should throw an ApiException with the error of the server', () async {
        when(() => client.get(any(), headers: any(named: 'headers'))).thenAnswer((_) async => http.Response(
            jsonEncode({'code': 'USER_NOT_FOUND', 'message': 'User not found', 'timestamp': '', 'path': ''}), 404));

        await expectLater(dataSource.getSummary(), throwsA(isA<ApiException>()));
      });
    });

    group('deleteAccount', () {
      test('should POST the authKey to the delete endpoint', () async {
        stubPost(http.Response('', 204));

        await dataSource.deleteAccount('YXV0aEtleQ==');

        final captured = verify(() => client.post(captureAny(), headers: any(named: 'headers'),
            body: captureAny(named: 'body'))).captured;
        expect((captured[0] as Uri).toString(), '$baseUrl/api/profile/delete/');
        expect(jsonDecode(captured[1] as String), {'authKey': 'YXV0aEtleQ=='});
      });

      test('should throw an ApiException with INCORRECT_PASSWORD when the authKey is wrong', () async {
        stubPost(http.Response(jsonEncode(
            {'code': 'INCORRECT_PASSWORD', 'message': 'Wrong', 'timestamp': '', 'path': '/api/profile/delete/'}),
            400));

        await expectLater(dataSource.deleteAccount('a2V5'),
            throwsA(isA<ApiException>().having((e) => e.errorResponse.code, 'code', 'INCORRECT_PASSWORD')));
      });

      test('should let a network error through', () async {
        when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
            .thenThrow(const SocketException('offline'));

        await expectLater(dataSource.deleteAccount('a2V5'), throwsA(isA<SocketException>()));
      });

      test('should wrap any other error as a connection error', () async {
        when(() => client.post(any(), headers: any(named: 'headers'), body: any(named: 'body')))
            .thenThrow(StateError('broken'));

        await expectLater(dataSource.deleteAccount('a2V5'), throwsA(isA<Exception>()));
      });
    });
  });
}
