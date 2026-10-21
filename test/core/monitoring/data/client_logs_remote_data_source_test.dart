import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:photo_manager_app/core/monitoring/data/client_logs_remote_data_source.dart';

void main() {
  group('ClientLogsRemoteDataSource', () {
    test('should post the lines to /api/client-logs/', () async {
      late http.Request sent;
      final dataSource = ClientLogsRemoteDataSource(
        client: MockClient((request) async {
          sent = request;
          return http.Response('', 204);
        }),
        baseUrl: 'https://api.test',
      );

      await dataSource.send([{'level': 'ERROR', 'event': 'UNCAUGHT_ERROR'}]);

      expect(sent.method, 'POST');
      expect(sent.url.toString(), 'https://api.test/api/client-logs/');
      expect(jsonDecode(sent.body), {
        'entries': [{'level': 'ERROR', 'event': 'UNCAUGHT_ERROR'}]
      });
    });

    test('should fail when the backend does not take them', () async {
      final dataSource = ClientLogsRemoteDataSource(
          client: MockClient((_) async => http.Response('{}', 400)), baseUrl: 'https://api.test');

      expect(() => dataSource.send([{'event': 'X'}]), throwsA(isA<http.ClientException>()));
    });
  });
}
