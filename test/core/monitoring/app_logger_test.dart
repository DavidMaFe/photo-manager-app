import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/errors/base/failures.dart';
import 'package:photo_manager_app/core/errors/base/generic_failure.dart';
import 'package:photo_manager_app/core/errors/handler/error_handler.dart';
import 'package:photo_manager_app/core/monitoring/app_logger.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_events.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_entry.dart';
import 'package:photo_manager_app/core/monitoring/domain/app_log_repository.dart';
import 'package:photo_manager_app/core/network/request_id_http_client.dart';

class MockAppLogRepository extends Mock implements AppLogRepository {}

class MockRequestIdHttpClient extends Mock implements RequestIdHttpClient {}

void main() {
  late MockAppLogRepository repository;
  late MockRequestIdHttpClient requestIds;
  late AppLogger logger;
  final now = DateTime.utc(2026, 10, 21, 16);

  setUpAll(() => registerFallbackValue(AppLogEntry(level: AppLogLevel.info, event: 'X', occurredAt: DateTime(2026))));

  setUp(() {
    repository = MockAppLogRepository();
    requestIds = MockRequestIdHttpClient();
    when(() => repository.enqueue(any())).thenAnswer((_) async {});
    when(() => repository.flush()).thenAnswer((_) async => 0);
    when(() => requestIds.lastServerErrorRequestId).thenReturn(null);
    logger = AppLogger(repository, requestIds: requestIds, now: () => now);
  });

  tearDown(() => logger.stop());

  List<AppLogEntry> queued() => verify(() => repository.enqueue(captureAny())).captured.cast<AppLogEntry>();

  group('AppLogger', () {
    test('should queue an event of the app with the current screen', () async {
      logger.currentScreen = 'synchronization';

      logger.record(const SyncFailed(background: true, reason: 'AUTH', uploaded: 3, failed: 1));
      await logger.flush();

      final entry = queued().single;
      expect(entry.level, AppLogLevel.warn);
      expect(entry.event, 'SYNC_FAILED');
      expect(entry.message, 'background=true reason=AUTH uploaded=3 failed=1');
      expect(entry.screen, 'synchronization');
      expect(entry.occurredAt, now);
    });

    test('should queue an uncaught error with its type, trace and the request of a recent server error', () async {
      when(() => requestIds.lastServerErrorRequestId).thenReturn('req-12345678');

      logger.recordError(StateError('No element for ana@example.com'), StackTrace.fromString('#0 main (package:a/b.dart)'));
      await logger.flush();

      final entry = queued().single;
      expect(entry.level, AppLogLevel.error);
      expect(entry.event, 'UNCAUGHT_ERROR');
      expect(entry.errorType, 'StateError');
      expect(entry.message, 'Bad state: No element for <email>');
      expect(entry.stackTrace, '#0 main (package:a/b.dart)');
      expect(entry.requestId, 'req-12345678');
    });

    group('recordHandled', () {
      test('should record the failures of the server', () async {
        logger.recordHandled(const ServerFailure(code: 'UPLOAD_FILE_ERROR'), Exception('upload'));
        await logger.flush();

        expect(queued().single, isA<AppLogEntry>().having((e) => e.event, 'event', 'SERVER_ERROR')
            .having((e) => e.errorType, 'errorType', 'UPLOAD_FILE_ERROR'));
      });

      test('should record the unknown codes of the backend', () async {
        logger.recordHandled(GenericFailure(backendCode: 'NEW_CODE', backendMessage: 'x'), Exception('api'));
        await logger.flush();

        expect(queued().single.event, 'UNKNOWN_SERVER_CODE');
      });

      test('should record a Dart error with its trace', () async {
        final error = _errorWithTrace();

        logger.recordHandled(const UnknownFailure(code: 'ERROR'), error);
        await logger.flush();

        final entry = queued().single;
        expect(entry.event, 'UNEXPECTED_ERROR');
        expect(entry.stackTrace, isNotNull);
      });

      test('should record an answer that could not be read', () async {
        logger.recordHandled(const ValidationFailure(), const FormatException('Unexpected character'));
        await logger.flush();

        expect(queued().single.event, 'PARSE_ERROR');
      });

      test('should not record the network nor what the user can fix', () async {
        logger.recordHandled(const NetworkFailure(), const SocketException('offline'));
        logger.recordHandled(const InvalidCredentialsFailure(), Exception('401'));
        logger.recordHandled(const ValidationFailure(code: 'VALIDATION_ERROR'), Exception('400'));
        await logger.flush();

        verifyNever(() => repository.enqueue(any()));
      });
    });

    test('should not fail nor record anything when the sending fails', () async {
      when(() => repository.flush()).thenThrow(Exception('offline'));
      logger.recordError(StateError('x'), null);

      await expectLater(logger.flush(), completes);
      verify(() => repository.enqueue(any())).called(1);
    });

    testWidgets('should send what is queued every thirty seconds', (tester) async {
      logger.start();

      await tester.pump(AppLogger.flushInterval);
      await tester.pump(AppLogger.flushInterval);
      logger.stop();

      verify(() => repository.flush()).called(2);
    });

    testWidgets('should send an error a few seconds after it happens', (tester) async {
      logger.recordError(StateError('x'), null);

      await tester.pump(AppLogger.errorFlushDelay);

      verify(() => repository.flush()).called(1);
    });

    testWidgets('should send a warning only with the next round', (tester) async {
      logger.record(const SyncFailed(background: false, reason: 'SYNC'));

      await tester.pump(AppLogger.errorFlushDelay);

      verifyNever(() => repository.flush());
    });
  });

  group('AppScreenObserver', () {
    testWidgets('should tell the logger the screen of the route shown', (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(MaterialApp(
        navigatorKey: key,
        navigatorObservers: [AppScreenObserver(logger)],
        home: const Text('home'),
      ));

      key.currentState!.push(MaterialPageRoute(settings: const RouteSettings(name: 'profile'),
          builder: (_) => const Text('profile')));
      await tester.pumpAndSettle();
      expect(logger.currentScreen, 'profile');

      key.currentState!.pop();
      await tester.pumpAndSettle();
      expect(logger.currentScreen, '/');
    });
  });

  group('ErrorHandler.onFailure', () {
    tearDown(() => ErrorHandler.onFailure = null);

    test('should give every handled failure with its error to the monitoring', () {
      final reported = <Object>[];
      ErrorHandler.onFailure = (failure, error) => reported..add(failure)..add(error);
      final error = Exception('anything');

      final failure = ErrorHandler.handleError(error);

      expect(reported, [failure, error]);
    });

    test('should still answer the failure when the monitoring fails', () {
      ErrorHandler.onFailure = (_, __) => throw StateError('monitoring broken');

      expect(ErrorHandler.handleError(const SocketException('offline')), isA<NetworkFailure>());
    });
  });
}

Error _errorWithTrace() {
  try {
    throw StateError('broken');
  } on StateError catch (e) {
    return e;
  }
}
