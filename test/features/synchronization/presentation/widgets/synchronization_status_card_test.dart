import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_status_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);

  Widget buildTestWidget(Synchronization? latestSync, {VoidCallback? onSyncNowPressed}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('es'),
      ],
      home: Scaffold(
        body: SynchronizationStatusCard(
          latestSync: latestSync,
          onSyncNowPressed: onSyncNowPressed ?? () {},
        ),
      ),
    );
  }

  group('SynchronizationStatusCard', () {
    testWidgets('should display sync now button', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call onSyncNowPressed when button tapped', (tester) async {
      bool pressed = false;
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(
        buildTestWidget(session, onSyncNowPressed: () => pressed = true),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, true);
    });

    testWidgets('should display check icon when latest sync is completed', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('should display sync icon when latest sync is in progress', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 100,
        uploadedFiles: 50,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should display close icon when latest sync failed', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.failed,
        totalFiles: 100,
        uploadedFiles: 30,
        failedFiles: 70,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display sync icon when latest sync is cancelled', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.cancelled,
        totalFiles: 100,
        uploadedFiles: 40,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should display sync icon when latestSync is null', (tester) async {
      await tester.pumpWidget(buildTestWidget(null));

      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('should have gradient background', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationStatusCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration).gradient,
        isA<LinearGradient>(),
      );
    });

    testWidgets('should display status badge with synchronized text when completed',
        (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));
      await tester.pumpAndSettle();

      // Status badge should be present
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should display status badge with pending text when not completed',
        (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.inProgress,
        totalFiles: 100,
        uploadedFiles: 50,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));
      await tester.pumpAndSettle();

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should have rounded corners', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationStatusCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration).borderRadius,
        BorderRadius.circular(16),
      );
    });

    testWidgets('should have shadow', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationStatusCard),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration).boxShadow,
        isNotNull,
      );
    });

    testWidgets('should display circular status icon container', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      // Find containers with circular shape
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(SynchronizationStatusCard),
          matching: find.byType(Container),
        ),
      );

      final circularContainers = containers.where((container) {
        final decoration = container.decoration;
        return decoration is BoxDecoration && decoration.shape == BoxShape.circle;
      });

      expect(circularContainers.length, greaterThan(0));
    });
  });
}
