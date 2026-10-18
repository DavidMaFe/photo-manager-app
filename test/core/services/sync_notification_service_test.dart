import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:photo_manager_app/core/services/sync_notification_service.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class MockFlutterLocalNotificationsPlugin extends Mock implements FlutterLocalNotificationsPlugin {}

void main() {
  late MockFlutterLocalNotificationsPlugin plugin;

  setUpAll(() => registerFallbackValue(const NotificationDetails()));

  setUp(() {
    plugin = MockFlutterLocalNotificationsPlugin();
    when(() => plugin.show(any(), any(), any(), any(), payload: any(named: 'payload'))).thenAnswer((_) async {});
  });

  SyncNotificationService service(String language) =>
      SyncNotificationService(plugin, strings: () => lookupAppLocalizations(Locale(language)));

  /// Title and body of the only notification shown.
  (String?, String?) shown() {
    final call = verify(() => plugin.show(any(), captureAny(), captureAny(), any(), payload: any(named: 'payload')));
    call.called(1);
    return (call.captured[0] as String?, call.captured[1] as String?);
  }

  group('SyncNotificationService', () {
    group('showSyncSuccessNotification', () {
      test('should tell in Spanish how many files were uploaded', () async {
        await service('es').showSyncSuccessNotification(filesUploaded: 3);

        expect(shown(), ('Copia completada', '3 archivos subidos'));
      });

      test('should tell in English how many files were uploaded', () async {
        await service('en').showSyncSuccessNotification(filesUploaded: 1);

        expect(shown(), ('Backup completed', '1 file uploaded'));
      });

      test('should say that everything was already backed up when nothing was uploaded', () async {
        await service('es').showSyncSuccessNotification(filesUploaded: 0);

        expect(shown(), ('Copia completada', 'Ya estaba todo copiado'));
      });
    });

    group('showSyncFailureNotification', () {
      test('should say that it will be tried again, without the technical error', () async {
        await service('es').showSyncFailureNotification(sessionExpired: false);

        expect(shown(), (
          'No se ha podido completar la copia',
          'Se volverá a intentar más tarde. Abre la app para ver qué ha pasado.',
        ));
      });

      test('should ask to log in again when the session expired', () async {
        await service('en').showSyncFailureNotification(sessionExpired: true);

        expect(shown(), (
          'The backup could not be completed',
          'Your session has expired. Log in again to keep backing up your photos.',
        ));
      });
    });

    group('showDownloadFinished', () {
      test('should tell how many files were saved to this phone', () async {
        await service('es').showDownloadFinished(saved: 1, failed: 0);

        expect(shown(), ('Descarga completada', '1 archivo guardado en este teléfono'));
      });

      test('should add how many files could not be saved', () async {
        await service('en').showDownloadFinished(saved: 4, failed: 2);

        expect(shown(), ('Download completed', '4 files saved to this phone · 2 could not be saved'));
      });
    });
  });
}
