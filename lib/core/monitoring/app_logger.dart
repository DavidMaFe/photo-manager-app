import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/base/generic_failure.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_event_log.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_event.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_repository.dart';
import 'package:photo_manager_app/core/monitoring/domain/log_sanitizer.dart';
import 'package:photo_manager_app/core/network/request_id_http_client.dart';

/// Records what the app wants seen in the monitoring and sends it to the backend (CLAUDE.md, «Logs and metrics»):
/// every [flushInterval], a few seconds after an error, and when the app goes to the background or comes back.
///
/// Recording never fails nor blocks: a line that cannot be queued is dropped, and a failed sending is never recorded
/// (it would loop); the lines wait for the next time.
class AppLogger implements AppEventLog {
  static const Duration flushInterval = Duration(seconds: 30);
  static const Duration errorFlushDelay = Duration(seconds: 5);

  final AppLogRepository _repository;
  final RequestIdHttpClient? _requestIds;
  final DateTime Function() _now;
  final Set<Future<void>> _pending = {};
  Timer? _periodic;
  Timer? _soon;
  bool _flushing = false;

  /// The screen the user is on ([AppScreenObserver]).
  String? currentScreen;

  AppLogger(this._repository, {RequestIdHttpClient? requestIds, DateTime Function()? now})
      : _requestIds = requestIds,
        _now = now ?? DateTime.now;

  void start() {
    _periodic ??= Timer.periodic(flushInterval, (_) => flush());
  }

  void stop() {
    _periodic?.cancel();
    _periodic = null;
    _soon?.cancel();
    _soon = null;
  }

  @override
  void record(AppLogEvent event) {
    _add(AppLogEntry(
      level: event.level,
      event: event.name,
      occurredAt: _now(),
      message: LogSanitizer.clean(event.message),
      screen: currentScreen,
    ));
  }

  @override
  void recordError(Object error, StackTrace? stackTrace, {String event = 'UNCAUGHT_ERROR'}) {
    _add(AppLogEntry(
      level: AppLogLevel.error,
      event: event,
      occurredAt: _now(),
      errorType: LogSanitizer.clean(error.runtimeType.toString(), maxLength: LogSanitizer.maxShort),
      message: LogSanitizer.clean(error.toString()),
      stackTrace: LogSanitizer.clean(stackTrace?.toString(), maxLength: LogSanitizer.maxStackTrace),
      screen: currentScreen,
      requestId: _requestIds?.lastServerErrorRequestId,
    ));
  }

  /// A failure the app handled ([ErrorHandler]). Only the ones that point to a bug or to the server are recorded:
  /// not the network, nor the answers the user can fix (validation, wrong password, limits).
  void recordHandled(Failure failure, Object error) {
    if (error is Error) {
      recordError(error, error.stackTrace, event: 'UNEXPECTED_ERROR');
    } else if (failure is ServerFailure || failure.code == 'INTERNAL_ERROR') {
      _add(_handled(AppLogLevel.warn, 'SERVER_ERROR', failure, error));
    } else if (failure is GenericFailure) {
      _add(_handled(AppLogLevel.warn, 'UNKNOWN_SERVER_CODE', failure, error));
    } else if (failure is UnknownFailure) {
      _add(_handled(AppLogLevel.error, 'UNEXPECTED_ERROR', failure, error));
    } else if (error is FormatException) {
      _add(_handled(AppLogLevel.warn, 'PARSE_ERROR', failure, error));
    }
  }

  /// Sends what is queued. Never throws.
  Future<void> flush() async {
    if (_flushing) {
      return;
    }
    _flushing = true;
    try {
      await Future.wait(List.of(_pending));
      await _repository.flush();
    } catch (_) {
      // Offline or the server is down: the lines wait in the queue
    } finally {
      _flushing = false;
    }
  }

  AppLogEntry _handled(AppLogLevel level, String event, Failure failure, Object error) => AppLogEntry(
        level: level,
        event: event,
        occurredAt: _now(),
        errorType: LogSanitizer.clean(failure.code ?? error.runtimeType.toString(), maxLength: LogSanitizer.maxShort),
        message: LogSanitizer.clean(error.toString()),
        screen: currentScreen,
        requestId: _requestIds?.lastServerErrorRequestId,
      );

  void _add(AppLogEntry entry) {
    late final Future<void> enqueued;
    enqueued = _repository.enqueue(entry).catchError((Object _) {}).whenComplete(() => _pending.remove(enqueued));
    _pending.add(enqueued);
    if (entry.level == AppLogLevel.error) {
      _soon ??= Timer(errorFlushDelay, () {
        _soon = null;
        flush();
      });
    }
  }
}

/// Tells [AppLogger] the screen the user is on: the name of its route.
class AppScreenObserver extends NavigatorObserver {
  final AppLogger logger;

  AppScreenObserver(this.logger);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _show(route);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _show(newRoute);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _show(previousRoute);

  void _show(Route<dynamic>? route) {
    final name = route?.settings.name;
    if (name != null && name.isNotEmpty) {
      logger.currentScreen = name;
    }
  }
}
