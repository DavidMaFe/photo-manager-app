import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

/// The innermost HTTP client: every request carries an `X-Request-Id`, the same id the backend writes in all the log
/// lines of that request. The server errors (5xx) are remembered for a while, so a line of the app about them can
/// say which request it was ([lastServerErrorRequestId]).
class RequestIdHttpClient extends http.BaseClient {
  static const String header = 'X-Request-Id';
  static const Duration rememberServerErrorsFor = Duration(seconds: 30);

  final http.Client _inner;
  final Uuid _uuid;
  final DateTime Function() _now;
  String? _lastServerErrorRequestId;
  DateTime? _lastServerErrorAt;

  RequestIdHttpClient(this._inner, {Uuid? uuid, DateTime Function()? now})
      : _uuid = uuid ?? const Uuid(),
        _now = now ?? DateTime.now;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final requestId = request.headers[header] ?? _uuid.v4();
    request.headers[header] = requestId;
    final response = await _inner.send(request);
    if (response.statusCode >= 500) {
      _lastServerErrorRequestId = response.headers[header.toLowerCase()] ?? requestId;
      _lastServerErrorAt = _now();
    }
    return response;
  }

  /// The id of the last request answered with a 5xx, if it was recent.
  String? get lastServerErrorRequestId {
    final at = _lastServerErrorAt;
    if (at == null || _now().difference(at) > rememberServerErrorsFor) {
      return null;
    }
    return _lastServerErrorRequestId;
  }

  @override
  void close() => _inner.close();
}
