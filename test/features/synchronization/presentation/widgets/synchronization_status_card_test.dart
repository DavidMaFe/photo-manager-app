import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/progress_ring.dart';
import 'package:photo_manager_app/features/sync_config/domain/entities/sync_config.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_status_card.dart';

import '../../../../fixtures/test_data.dart';
import '../../../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;

  Synchronization sync(SynchronizationStatus status, {int total = 128, int uploaded = 128, int failed = 0}) {
    return Synchronization(
      id: 's1',
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: status,
      totalFiles: total,
      uploadedFiles: uploaded,
      failedFiles: failed,
    );
  }

  Future<void> pump(
    WidgetTester tester, {
    Synchronization? latest,
    SyncConfig? config,
    VoidCallback? onSyncNow,
    VoidCallback? onSettings,
    LiveBackup? live,
    VoidCallback? onCancel,
  }) {
    setUpCustomScreenSize(tester, 390, 900);
    return tester.pumpWidget(makeTestableWidget(Scaffold(
      body: SingleChildScrollView(
        child: SynchronizationStatusCard(
          latestSync: latest,
          onSyncNowPressed: onSyncNow ?? () {},
          config: config,
          onSettingsPressed: onSettings,
          live: live,
          onCancelPressed: onCancel,
        ),
      ),
    )));
  }

  ProgressRing ring(WidgetTester tester) => tester.widget<ProgressRing>(find.byType(ProgressRing));

  group('SynchronizationStatusCard', () {
    // ==================== STATUS TESTS ====================

    testWidgets('should invite to back up when there is no backup yet', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(find.text("You haven't backed up yet"), findsOneWidget);
      expect(ring(tester).value, 0);
    });

    testWidgets('should show all safe with a full safe ring after a completed backup', (tester) async {
      // Arrange & Act
      await pump(tester, latest: sync(SynchronizationStatus.completed));

      // Assert
      expect(find.text('All backed up'), findsOneWidget);
      expect(find.text('Last backup 2 hours ago · 128 items'), findsOneWidget);
      expect(ring(tester).value, 1);
      expect(ring(tester).color, p.safe);
    });

    testWidgets('should measure the last backup from its end time', (tester) async {
      // Arrange
      final now = DateTime.now();
      final finished = Synchronization(
        id: 's1',
        startedAt: now.subtract(const Duration(hours: 5)),
        status: SynchronizationStatus.completed,
        totalFiles: 128,
        uploadedFiles: 128,
        failedFiles: 0,
        completedAt: now.subtract(const Duration(hours: 2, minutes: 1)),
      );

      // Act
      await pump(tester, latest: finished);

      // Assert
      expect(find.text('Last backup 2 hours ago · 128 items'), findsOneWidget);
    });

    testWidgets('should show the progress percentage while a backup runs', (tester) async {
      // Arrange & Act
      await pump(tester, latest: sync(SynchronizationStatus.inProgress, total: 128, uploaded: 45));

      // Assert
      expect(find.text('Backing up 45 of 128'), findsOneWidget);
      expect(find.text('35%'), findsOneWidget);
      expect(ring(tester).color, p.accent);
    });

    testWidgets('should show the failure state with the failure count', (tester) async {
      // Arrange & Act
      await pump(tester, latest: sync(SynchronizationStatus.failed, failed: 3));

      // Assert
      expect(find.text("The last backup didn't finish"), findsOneWidget);
      expect(find.text('2 hours ago · 3 failures'), findsOneWidget);
      expect(ring(tester).color, p.danger);
    });

    testWidgets('should show the cancelled state', (tester) async {
      // Arrange & Act
      await pump(tester, latest: sync(SynchronizationStatus.cancelled));

      // Assert
      expect(find.text('The last backup was cancelled'), findsOneWidget);
    });

    testWidgets('should not use a gradient background', (tester) async {
      // Arrange & Act
      await pump(tester, latest: sync(SynchronizationStatus.completed));

      // Assert
      final gradients = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.decoration is BoxDecoration && (c.decoration as BoxDecoration).gradient != null);
      expect(gradients, isEmpty);
    });

    testWidgets('should start a backup from the main button', (tester) async {
      // Arrange
      var taps = 0;
      await pump(tester, onSyncNow: () => taps++);

      // Act
      await tester.tap(find.text('Back up now'));

      // Assert
      expect(taps, 1);
    });

    // ==================== CONDITION PILLS TESTS ====================

    testWidgets('should show daily schedule, wifi and battery conditions', (tester) async {
      // Arrange & Act
      await pump(tester, config: TestSyncConfigs.dailySync, onSettings: () {});

      // Assert
      expect(find.text('Daily · 02:00'), findsOneWidget);
      expect(find.text('Wi-Fi only'), findsOneWidget);
      expect(find.text('Charging or >15%'), findsOneWidget);
    });

    testWidgets('should show the weekday for weekly backups and any network', (tester) async {
      // Arrange & Act
      await pump(tester, config: TestSyncConfigs.weeklySync.copyWith(networkPreference: TestSyncConfigs.dailySyncAnyConditions.networkPreference));

      // Assert
      expect(find.text('Mon · 01:00'), findsOneWidget);
      expect(find.text('Wi-Fi and data'), findsOneWidget);
    });

    testWidgets('should say when automatic backup is off', (tester) async {
      // Arrange & Act
      await pump(tester, config: TestSyncConfigs.disabled);

      // Assert
      expect(find.text('Automatic backup off'), findsOneWidget);
      expect(find.text('Wi-Fi only'), findsNothing);
    });

    testWidgets('should hide the pills until the config is known', (tester) async {
      // Arrange & Act
      await pump(tester);

      // Assert
      expect(find.byType(BackupConditionsRow), findsNothing);
    });

    testWidgets('should open the backup settings', (tester) async {
      // Arrange
      var taps = 0;
      await pump(tester, config: TestSyncConfigs.dailySync, onSettings: () => taps++);

      // Act
      await tester.tap(find.byTooltip('Backup settings'));

      // Assert
      expect(taps, 1);
    });

    // ==================== LIVE BACKUP TESTS ====================

    testWidgets('should show the running backup progress and time left', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        live: const LiveBackup(
          phase: LiveBackupPhase.uploading,
          uploaded: 25,
          total: 100,
          remaining: Duration(minutes: 4),
        ),
      );

      // Assert
      expect(find.text('Backing up 25 of 100'), findsOneWidget);
      expect(find.text('About 4 min left'), findsOneWidget);
      expect(ring(tester).value, 0.25);
      expect(find.text('25%'), findsOneWidget);
      expect(find.text('Back up now'), findsNothing);
    });

    testWidgets('should not invent a time left before there is enough data', (tester) async {
      // Arrange & Act
      await pump(tester, live: const LiveBackup(phase: LiveBackupPhase.uploading, uploaded: 1, total: 100));

      // Assert
      expect(find.text('Backup in progress'), findsOneWidget);
      expect(find.textContaining('min left'), findsNothing);
    });

    testWidgets('should add how much is left to upload to the time left', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        live: const LiveBackup(
          phase: LiveBackupPhase.uploading,
          uploaded: 25,
          total: 100,
          remaining: Duration(minutes: 3),
          remainingBytes: 210 * 1024 * 1024,
        ),
      );

      // Assert
      expect(find.text('About 3 min left · 210 MB left to upload'), findsOneWidget);
    });

    testWidgets('should show how much is left to upload before the time is known', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        live: const LiveBackup(phase: LiveBackupPhase.uploading, uploaded: 1, total: 100, remainingBytes: 5 * 1024 * 1024),
      );

      // Assert
      expect(find.text('5 MB left to upload'), findsOneWidget);
      expect(find.text('Backup in progress'), findsNothing);
    });

    testWidgets('should say less than a minute is left', (tester) async {
      // Arrange & Act
      await pump(
        tester,
        live: const LiveBackup(
          phase: LiveBackupPhase.uploading,
          uploaded: 98,
          total: 100,
          remaining: Duration(seconds: 20),
        ),
      );

      // Assert
      expect(find.text('Less than a minute left'), findsOneWidget);
    });

    testWidgets('should show the preparing and finishing phases', (tester) async {
      // Arrange & Act
      await pump(tester, live: const LiveBackup(phase: LiveBackupPhase.scanning));

      // Assert
      expect(find.text('Preparing the backup…'), findsOneWidget);
      expect(find.text('Looking for new photos'), findsOneWidget);

      // Act
      await pump(tester, live: const LiveBackup(phase: LiveBackupPhase.finishing, uploaded: 1, total: 1));

      // Assert
      expect(find.text('Finishing the backup…'), findsOneWidget);
    });

    testWidgets('should cancel the running backup and offer no pause', (tester) async {
      // Arrange
      var cancels = 0;
      await pump(
        tester,
        live: const LiveBackup(phase: LiveBackupPhase.uploading, uploaded: 2, total: 10),
        onCancel: () => cancels++,
      );

      // Act
      await tester.tap(find.text('Cancel'));

      // Assert
      expect(cancels, 1);
      expect(find.textContaining('Pause'), findsNothing);
    });

    testWidgets('should disable cancel while the backup is being cancelled', (tester) async {
      // Arrange
      var cancels = 0;
      await pump(
        tester,
        live: const LiveBackup(phase: LiveBackupPhase.cancelling, uploaded: 2, total: 10),
        onCancel: () => cancels++,
      );

      // Act
      await tester.tap(find.text('Cancel'), warnIfMissed: false);

      // Assert
      expect(find.text('Cancelling…'), findsOneWidget);
      expect(cancels, 0);
    });
  });
}
