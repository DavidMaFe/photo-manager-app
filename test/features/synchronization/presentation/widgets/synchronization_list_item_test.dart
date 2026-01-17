import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_list_item.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  final testDate = DateTime(2024, 1, 15);

  Widget buildTestWidget(Synchronization session, {VoidCallback? onTap}) {
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
        body: SynchronizationListItem(
          session: session,
          onTap: onTap,
        ),
      ),
    );
  }

  group('SynchronizationListItem', () {
    testWidgets('should display session information', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byType(SynchronizationListItem), findsOneWidget);
    });

    testWidgets('should display completed status icon', (tester) async {
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

    testWidgets('should display in progress status icon', (tester) async {
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

    testWidgets('should display failed status icon', (tester) async {
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

    testWidgets('should display cancelled status icon', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.cancelled,
        totalFiles: 100,
        uploadedFiles: 40,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
    });

    testWidgets('should display chevron right icon', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      bool tapped = false;
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session, onTap: () => tapped = true));

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      expect(tapped, true);
    });

    testWidgets('should not crash when onTap is null', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.completed,
        totalFiles: 100,
        uploadedFiles: 100,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session, onTap: null));

      await tester.tap(find.byType(InkWell));
      await tester.pump();

      // Should not crash
      expect(find.byType(SynchronizationListItem), findsOneWidget);
    });

    testWidgets('should display completed status with green background', (tester) async {
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
          of: find.byType(SynchronizationListItem),
          matching: find.byType(Container),
        ).at(1), // The status icon container
      );

      expect(
        (container.decoration as BoxDecoration).color,
        const Color(0xFFDCFCE7), // Green background for completed
      );
    });

    testWidgets('should display in progress status with yellow background',
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

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationListItem),
          matching: find.byType(Container),
        ).at(1),
      );

      expect(
        (container.decoration as BoxDecoration).color,
        const Color(0xFFFEF3C7), // Yellow background for in progress
      );
    });

    testWidgets('should display failed status with red background', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.failed,
        totalFiles: 100,
        uploadedFiles: 30,
        failedFiles: 70,
      );

      await tester.pumpWidget(buildTestWidget(session));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationListItem),
          matching: find.byType(Container),
        ).at(1),
      );

      expect(
        (container.decoration as BoxDecoration).color,
        const Color(0xFFFEE2E2), // Red background for failed
      );
    });

    testWidgets('should display cancelled status with gray background', (tester) async {
      final session = Synchronization(
        id: 'sync-1',
        startedAt: testDate,
        status: SynchronizationStatus.cancelled,
        totalFiles: 100,
        uploadedFiles: 40,
        failedFiles: 0,
      );

      await tester.pumpWidget(buildTestWidget(session));

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(SynchronizationListItem),
          matching: find.byType(Container),
        ).at(1),
      );

      expect(
        (container.decoration as BoxDecoration).color,
        const Color(0xFFF3F4F6), // Gray background for cancelled
      );
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
          of: find.byType(SynchronizationListItem),
          matching: find.byType(Container),
        ).first,
      );

      expect(
        (container.decoration as BoxDecoration).borderRadius,
        BorderRadius.circular(12),
      );
    });
  });
}
