import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:photo_manager_app/features/profile/presentation/widgets/sync_config_summary.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/l10n/app_localizations_en.dart';
import 'package:photo_manager_app/l10n/app_localizations_es.dart';

import '../../../../fixtures/test_data.dart';

void main() {
  final en = AppLocalizationsEn();
  final es = AppLocalizationsEs();

  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('es');
  });

  group('SyncConfigSummary', () {
    group('schedule', () {
      test('should describe daily backups with the network', () {
        expect(SyncConfigSummary.schedule(TestSyncConfigs.dailySync, en), 'Daily at 02:00 · Wi-Fi only');
      });

      test('should describe weekly backups with the weekday', () {
        expect(SyncConfigSummary.schedule(TestSyncConfigs.weeklySync, es), 'Lunes a las 1:00 · Solo WiFi');
      });

      test('should say off when disabled or unknown', () {
        expect(SyncConfigSummary.schedule(TestSyncConfigs.disabled, en), 'Automatic backup off');
        expect(SyncConfigSummary.schedule(null, en), 'Automatic backup off');
      });
    });

    group('notifications', () {
      test('should map the notification flags', () {
        expect(SyncConfigSummary.notifications(TestSyncConfigs.dailySync, en), 'Failures only');
        expect(SyncConfigSummary.notifications(TestSyncConfigs.dailySyncAnyConditions, en), 'All');
        expect(SyncConfigSummary.notifications(TestSyncConfigs.onlySuccessNotifications, en), 'Finished only');
        expect(SyncConfigSummary.notifications(TestSyncConfigs.noNotifications, en), 'Off');
      });
    });
  });

  group('SyncConfigLoader', () {
    testWidgets('should build with the loaded config', (tester) async {
      // Arrange
      SyncConfig? seen;
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: SyncConfigLoader(
          load: () async => TestSyncConfigs.dailySync,
          builder: (_, config, loading) {
            if (!loading) seen = config;
            return const SizedBox();
          },
        ),
      ));

      // Act
      await tester.pump();

      // Assert
      expect(seen, TestSyncConfigs.dailySync);
    });
  });
}
