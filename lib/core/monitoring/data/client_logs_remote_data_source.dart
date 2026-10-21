import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';

/// POST /api/client-logs/: at most [maxBatch] lines. The client adds the token when there is a session, so the
/// backend knows the user; without one (login, registration) they go anyway.
class ClientLogsRemoteDataSource {
  static const int maxBatch = 50;

  final http.Client client;
  final String baseUrl;

  ClientLogsRemoteDataSource({required this.client, this.baseUrl = DataConstants.backendBaseUrl});

  /// Throws on any answer that is not a 2xx: the lines stay in the queue.
  Future<void> send(List<Map<String, dynamic>> entries) async {
    final response = await client.post(Uri.parse('$baseUrl/api/client-logs/'),
        headers: HttpHeadersUtil.getJsonHeaders(), body: jsonEncode({'entries': entries}));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw http.ClientException('client-logs answered ${response.statusCode}');
    }
  }
}
