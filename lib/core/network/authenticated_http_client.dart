import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:photo_manager_app/core/events/app_event_bus.dart';
import 'package:photo_manager_app/core/events/app_events.dart';
import 'package:photo_manager_app/core/services/timezone_service.dart';
import 'package:photo_manager_app/core/utils/http_headers_util.dart';
import 'package:photo_manager_app/features/auth/data/data_sources/auth_local_data_source.dart';


/// HTTP client wrapper that automatically handles token refresh on 401 responses.
///
/// This client transparently:
/// - Injects `Authorization: Bearer <token>` into every request.
/// - Adds the `X-Timezone` header when the caller did not set it.
/// - Intercepts HTTP 401 responses and attempts a token refresh.
/// - Retries the original request with the new token — completely invisible to callers.
/// - Prevents concurrent refresh calls with a mutex (Completer-based).
/// - Fires [AuthenticationFailedEvent] on the [AppEventBus] when the refresh itself
///   fails (e.g. expired refresh token), so [AuthBloc] can force a logout.
///
/// ### Why request copying is required
/// [http.BaseRequest] objects are **single-use**: after [_inner.send()] is called,
/// the request is finalised and cannot be sent again. To retry after a token refresh
/// we must build a fresh [http.Request] from the original's metadata each time.
class AuthenticatedHttpClient extends http.BaseClient {

  final http.Client _inner;
  final AuthLocalDataSource _authLocalDataSource;
  final Future<void> Function() _onTokenRefresh;
  final AppEventBus _eventBus;

  // Mutex: prevents multiple concurrent refresh requests.
  bool _isRefreshing = false;
  Completer<void>? _refreshCompleter;

  AuthenticatedHttpClient({
    required http.Client client,
    required AuthLocalDataSource authLocalDataSource,
    required Future<void> Function() onTokenRefresh,
    required AppEventBus eventBus,
  })  : _inner = client,
        _authLocalDataSource = authLocalDataSource,
        _onTokenRefresh = onTokenRefresh,
        _eventBus = eventBus;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // MultipartRequest bodies are single-use streams — once finalize() is
    // called the data cannot be replayed, so full retry-on-401 is not possible.
    //
    // Instead we apply two improvements over the naive "inject token and go":
    //
    // 1. **Wait for any concurrent refresh** before injecting the token.
    //    If a non-multipart request just triggered a token refresh (e.g. a
    //    session call got a 401 right before the upload starts), we wait for
    //    that refresh to complete so we inject the freshest possible token.
    //
    // 2. **Trigger a background refresh on 401**. If the upload itself gets a
    //    401 (token expired mid-upload), we start a background refresh so that
    //    all subsequent requests in the loop (including the next upload and the
    //    session completion call) use the new token. The current upload will
    //    fail, but the rest of the sync session can continue successfully.
    if (request is http.MultipartRequest) {
      // Step 1: If a refresh is already in progress, wait for it.
      if (_isRefreshing && _refreshCompleter != null) {
        try {
          await _refreshCompleter!.future;
        } catch (_) {
          // The concurrent refresh failed — proceed with whatever token we
          // have. The upload may also fail, but that is handled below.
        }
      }

      final String? token = await _authLocalDataSource.getToken();
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      _addTimezone(request.headers);

      final response = await _inner.send(request);

      // Step 2: Trigger a background refresh on 401 so subsequent requests
      // use the new token. We cannot retry this upload (stream consumed).
      if (response.statusCode == 401 && !_isRefreshing) {
        _triggerTokenRefreshInBackground();
      }

      return response;
    }

    // Capture body bytes BEFORE the first send so we can rebuild fresh copies of
    // the request for the initial attempt and for any retry after token refresh.
    // http.Request is single-use: finalize() cannot be called twice.
    final Uint8List bodyBytes = _captureBodyBytes(request);

    // --- Initial send ---
    final String? token = await _authLocalDataSource.getToken();
    http.StreamedResponse response = await _inner.send(
      _buildRequest(request, token, bodyBytes),
    );

    if (response.statusCode != 401) {
      return response;
    }

    // --- 401 received: handle token refresh ---

    if (_isRefreshing && _refreshCompleter != null) {
      // Another concurrent request is already refreshing; wait for it.
      try {
        await _refreshCompleter!.future;
      } catch (_) {
        // The refresh that the other request started has failed.
        // Return the 401 response — the error will propagate to the caller normally.
        return response;
      }

      // Refresh succeeded via the other request; retry with the new token.
      final String? newToken = await _authLocalDataSource.getToken();
      return await _inner.send(_buildRequest(request, newToken, bodyBytes));
    }

    // This is the first request to encounter 401 — start the refresh.
    _isRefreshing = true;
    _refreshCompleter = Completer<void>();

    try {
      await _onTokenRefresh();
      // Refresh succeeded — signal waiting requests.
      _refreshCompleter!.complete();
    } catch (e) {
      // Refresh failed (e.g. refresh token expired/revoked).
      _refreshCompleter!.completeError(e);
      _isRefreshing = false;
      _refreshCompleter = null;
      // Notify AuthBloc so it can force logout and redirect to login.
      _eventBus.fire(const AuthenticationFailedEvent());
      rethrow;
    }

    _isRefreshing = false;
    _refreshCompleter = null;

    // Retry the original request with the new token (fresh copy).
    final String? newToken = await _authLocalDataSource.getToken();
    return await _inner.send(_buildRequest(request, newToken, bodyBytes));
  }

  /// Reads the body bytes from [request] without consuming it.
  ///
  /// For [http.Request] the bytes are stored in-memory and can be read
  /// before [finalize()] is called. For [http.MultipartRequest] and other
  /// streaming types we cannot safely capture the body, so we return an empty
  /// list — those request types are fire-and-forget and do not support retry.
  Uint8List _captureBodyBytes(http.BaseRequest request) {
    if (request is http.Request) {
      return Uint8List.fromList(request.bodyBytes);
    }
    return Uint8List(0);
  }

  /// Builds a fresh, un-finalised [http.Request] from [original]'s metadata,
  /// injecting [token] as the `Authorization` header and restoring [bodyBytes].
  http.Request _buildRequest(
    http.BaseRequest original,
    String? token,
    Uint8List bodyBytes,
  ) {
    final request = http.Request(original.method, original.url);

    // Copy all original headers (Content-Type, Accept, etc.).
    request.headers.addAll(original.headers);
    _addTimezone(request.headers);

    // Inject / override the Authorization header.
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    // Restore body for POST / PUT / PATCH requests.
    if (bodyBytes.isNotEmpty) {
      request.bodyBytes = bodyBytes;
    }

    return request;
  }

  /// Adds the device time zone unless the caller already set one.
  void _addTimezone(Map<String, String> headers) {
    headers.putIfAbsent(HttpHeadersUtil.timezoneHeader, () => TimezoneService.current);
  }

  /// Starts a token refresh in the background (fire-and-forget style).
  ///
  /// Used exclusively by the [MultipartRequest] path when a 401 is received.
  /// Because the multipart body is already consumed we cannot retry the
  /// upload, but we can refresh the token so all subsequent requests use the
  /// new credential. Waiting requests detect [_isRefreshing] / [_refreshCompleter]
  /// and will wait for this refresh before proceeding.
  void _triggerTokenRefreshInBackground() {
    _isRefreshing = true;
    final completer = Completer<void>();
    _refreshCompleter = completer;

    _onTokenRefresh().then((_) {
      completer.complete();
      _isRefreshing = false;
      _refreshCompleter = null;
    }).catchError((Object e) {
      completer.completeError(e);
      _isRefreshing = false;
      _refreshCompleter = null;
      _eventBus.fire(const AuthenticationFailedEvent());
    });
  }

  @override
  void close() {
    _inner.close();
  }
}
