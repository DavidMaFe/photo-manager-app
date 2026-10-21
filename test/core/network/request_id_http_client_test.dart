import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:photo_manager_app/core/network/request_id_http_client.dart';

void main() {
  group('RequestIdHttpClient', () {
    test('should give every request its own X-Request-Id', () async {
      final ids = <String?>[];
      final client = RequestIdHttpClient(MockClient((request) async {
        ids.add(request.headers['X-Request-Id']);
        return http.Response('', 200);
      }));

      await client.get(Uri.parse('https://api.test/a'));
      await client.get(Uri.parse('https://api.test/b'));

      expect(ids, everyElement(matches(RegExp(r'^[0-9a-f-]{36}$'))));
      expect(ids.toSet(), hasLength(2));
    });

    test('should remember the id of a recent server error', () async {
      var now = DateTime(2026, 10, 21, 16);
      late String id;
      final client = RequestIdHttpClient(MockClient((request) async {
        id = request.headers['X-Request-Id']!;
        return http.Response('', 500);
      }), now: () => now);

      await client.get(Uri.parse('https://api.test/a'));

      expect(client.lastServerErrorRequestId, id);
      now = now.add(const Duration(minutes: 1));
      expect(client.lastServerErrorRequestId, isNull);
    });

    test('should not remember the answers that are not server errors', () async {
      final client = RequestIdHttpClient(MockClient((_) async => http.Response('', 404)));

      await client.get(Uri.parse('https://api.test/a'));

      expect(client.lastServerErrorRequestId, isNull);
    });
  });
}
