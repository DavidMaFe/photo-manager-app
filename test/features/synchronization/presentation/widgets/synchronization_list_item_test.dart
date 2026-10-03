import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/synchronization/domain/entities/synchronization.dart';
import 'package:photo_manager_app/features/synchronization/domain/enums/synchronization_status.dart';
import 'package:photo_manager_app/features/synchronization/presentation/widgets/synchronization_list_item.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  const p = AppPalette.light;
  final today = DateTime.now();
  final at3 = DateTime(today.year, today.month, today.day, 3, 0);

  Synchronization session(SynchronizationStatus status, {int uploaded = 12, int failed = 0}) {
    return Synchronization(
      id: 's1',
      startedAt: at3,
      status: status,
      totalFiles: 20,
      uploadedFiles: uploaded,
      failedFiles: failed,
    );
  }

  Future<void> pump(WidgetTester tester, Synchronization s, {VoidCallback? onTap}) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(body: SynchronizationListItem(session: s, onTap: onTap))));
  }

  Color iconBackground(WidgetTester tester) {
    final box = tester.widget<Container>(find.ancestor(of: find.byType(Icon), matching: find.byType(Container)).first);
    return (box.decoration as BoxDecoration).color!;
  }

  group('SynchronizationListItem', () {
    testWidgets('should show saved items with a safe check', (tester) async {
      // Arrange & Act
      await pump(tester, session(SynchronizationStatus.completed, uploaded: 12));

      // Assert
      expect(find.text('12 items saved'), findsOneWidget);
      expect(find.text('Today, 03:00'), findsOneWidget);
      expect(find.byIcon(Symbols.check_rounded), findsOneWidget);
      expect(iconBackground(tester), p.safeSoft);
    });

    testWidgets('should show the failures of an incomplete backup', (tester) async {
      // Arrange & Act
      await pump(tester, session(SynchronizationStatus.failed, failed: 1));

      // Assert
      expect(find.text('Incomplete backup · 1 failure'), findsOneWidget);
      expect(iconBackground(tester), p.dangerSoft);
    });

    testWidgets('should show a cancelled backup in neutral colors', (tester) async {
      // Arrange & Act
      await pump(tester, session(SynchronizationStatus.cancelled));

      // Assert
      expect(find.text('Backup cancelled'), findsOneWidget);
      expect(iconBackground(tester), p.surface2);
    });

    testWidgets('should show a running backup in accent', (tester) async {
      // Arrange & Act
      await pump(tester, session(SynchronizationStatus.inProgress));

      // Assert
      expect(find.text('Backup in progress'), findsOneWidget);
      expect(iconBackground(tester), p.accentSoft);
    });

    testWidgets('should call onTap when tappable', (tester) async {
      // Arrange
      var taps = 0;
      await pump(tester, session(SynchronizationStatus.completed), onTap: () => taps++);

      // Act
      await tester.tap(find.byType(SynchronizationListItem));

      // Assert
      expect(taps, 1);
    });
  });
}
