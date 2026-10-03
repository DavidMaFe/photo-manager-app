import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_header.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_header.dart';

import '../../../../helpers/widget_test_helper.dart';

void main() {
  Future<void> pump(WidgetTester tester, TrashHeader header) {
    return tester.pumpWidget(makeTestableWidget(Scaffold(appBar: header)));
  }

  group('TrashHeader', () {
    testWidgets('should show the trash title and the Empty action', (tester) async {
      // Arrange
      var empties = 0;
      await pump(tester, TrashHeader(
        isSelectionMode: false,
        selectedCount: 0,
        onCancelSelection: () {},
        onEmptyTrash: () => empties++,
      ));

      // Act
      await tester.tap(find.text('Empty'));

      // Assert
      expect(find.byType(SecondaryTopBar), findsOneWidget);
      expect(find.text('Trash'), findsOneWidget);
      expect(empties, 1);
    });

    testWidgets('should hide Empty when there is nothing to empty', (tester) async {
      // Arrange & Act
      await pump(tester, TrashHeader(
        isSelectionMode: false,
        selectedCount: 0,
        canEmpty: false,
        onCancelSelection: () {},
        onEmptyTrash: () {},
      ));

      // Assert
      expect(find.text('Empty'), findsNothing);
    });

    testWidgets('should show the selection header in selection mode', (tester) async {
      // Arrange
      var cancels = 0;
      var selectAll = 0;
      await pump(tester, TrashHeader(
        isSelectionMode: true,
        selectedCount: 3,
        onCancelSelection: () => cancels++,
        onEmptyTrash: () {},
        onSelectAll: () => selectAll++,
      ));

      // Act
      await tester.tap(find.byTooltip('Exit selection'));
      await tester.tap(find.text('All'));

      // Assert
      expect(find.byType(SelectionHeader), findsOneWidget);
      expect(find.text('3 selected'), findsOneWidget);
      expect(cancels, 1);
      expect(selectAll, 1);
    });

    test('should size itself for each mode', () {
      final normal = TrashHeader(isSelectionMode: false, selectedCount: 0, onCancelSelection: () {}, onEmptyTrash: () {});
      final selection = TrashHeader(isSelectionMode: true, selectedCount: 1, onCancelSelection: () {}, onEmptyTrash: () {});
      expect(normal.preferredSize.height, SecondaryTopBar.height);
      expect(selection.preferredSize.height, 72);
    });
  });
}
