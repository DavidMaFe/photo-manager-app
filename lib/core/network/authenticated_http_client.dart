import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';


/// HTTP client wrapper that automatically handles token refresh on 401 responses
///
/// This client automatically:
/// - Adds Authorization header to all requests
/// - Detects 401 responses and attempts token refresh
/// - Retries the original request with the new token
/// - Prevents concurrent refresh requests using a mutex pattern
class AuthenticatedHttpClient extends http.BaseClient {

  final http.Client _inner;
  final AuthLocalDataSource _authLocalDataSource;
  final Future<void> Function() _onTokenRefresh;

  // Mutex to prevent concurrent refresh requests
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthenticatedHttpClient({
    required http.Client client,
    required AuthLocalDataSource authLocalDataSource,
    required Future<void> Function() onTokenRefresh,
  })  : _inner = client,
        _authLocalDataSource = authLocalDataSource,
        _onTokenRefresh = onTokenRefresh;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Add authorization header if token exists
    final token = await _authLocalDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Send the original request
    http.StreamedResponse response = await _inner.send(request);

    // If 401, attempt token refresh and retry
    if (response.statusCode == 401) {
      // Wait if another request is already refreshing
      if (_isRefreshing && _refreshCompleter != null) {
        await _refreshCompleter!.future;

        // Retry with new token
        final newToken = await _authLocalDataSource.getToken();
        if (newToken != null && newToken.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $newToken';
          return await _inner.send(request);
        }
      }

      // Start refresh process
      if (!_isRefreshing) {
        _isRefreshing = true;
        _refreshCompleter = Completer<void>();

        try {
          // Call the refresh callback (provided by DI container)
          await _onTokenRefresh();
          _refreshCompleter!.complete();

          // Retry the original request with new token
          final newToken = await _authLocalDataSource.getToken();
          if (newToken != null && newToken.isNotEmpty) {
            request.headers['Authorization'] = 'Bearer $newToken';
            response = await _inner.send(request);
          }
        } catch (e) {
          _refreshCompleter!.completeError(e);
          // Refresh failed, let the error propagate
        } finally {
          _isRefreshing = false;
          _refreshCompleter = null;
        }
      }
    }

    return response;
  }

  @override
  void close() {
    _inner.close();
  }
}
