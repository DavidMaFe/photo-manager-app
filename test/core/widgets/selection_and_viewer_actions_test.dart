import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/core/widgets/selection_action_bar.dart';

import '../../helpers/widget_test_helper.dart';

void main() {
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  group('SelectionActionBar', () {
    testWidgets('should show each action with its label and the optional line', (tester) async {
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        bottomNavigationBar: SelectionActionBar(
          label: 'Up to 3 covers',
          actions: [
            SelectionAction(icon: Symbols.cloud_upload_rounded, label: 'Save', onPressed: () {},
                style: SelectionActionStyle.primary),
            SelectionAction(icon: Symbols.delete_rounded, label: 'Delete', onPressed: () {},
                style: SelectionActionStyle.danger),
          ],
        ),
      )));

      expect(find.text('Up to 3 covers'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('should open the menu of an action and run the chosen option', (tester) async {
      var shared = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        bottomNavigationBar: SelectionActionBar(actions: [
          SelectionAction(
            icon: Symbols.more_horiz_rounded,
            label: 'More',
            onPressed: () {},
            menu: [SelectionMenuItem(icon: Symbols.share_rounded, label: 'Share', onSelected: () => shared++)],
          ),
        ]),
      )));

      await tester.tap(find.text('More'));
      await settle(tester);
      await tester.tap(find.text('Share'));
      await settle(tester);

      expect(shared, 1);
    });

    testWidgets('should not open the menu of a disabled action', (tester) async {
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        bottomNavigationBar: SelectionActionBar(actions: [
          SelectionAction(
            icon: Symbols.more_horiz_rounded,
            label: 'More',
            onPressed: null,
            menu: [SelectionMenuItem(icon: Symbols.share_rounded, label: 'Share', onSelected: () {})],
          ),
        ]),
      )));

      await tester.tap(find.text('More'));
      await settle(tester);

      expect(find.text('Share'), findsNothing);
    });
  });

  group('MediaViewerAction', () {
    testWidgets('should dim a disabled action', (tester) async {
      await tester.pumpWidget(makeTestableWidget(const Scaffold(
          body: MediaViewerAction(icon: Symbols.download_done_rounded, label: 'On phone', onPressed: null))));

      final opacity = tester.widget<Opacity>(find.ancestor(of: find.text('On phone'), matching: find.byType(Opacity)));
      expect(opacity.opacity, lessThan(1));
    });

    testWidgets('should open the menu of More and run the chosen option', (tester) async {
      var deleted = 0;
      await tester.pumpWidget(makeTestableWidget(Scaffold(
        body: Center(
          child: MediaViewerMoreAction(label: 'More', items: [
            MediaViewerMenuItem(icon: Symbols.delete_rounded, label: 'Delete', destructive: true,
                onSelected: () => deleted++),
          ]),
        ),
      )));

      await tester.tap(find.text('More'));
      await settle(tester);
      await tester.tap(find.text('Delete'));
      await settle(tester);

      expect(deleted, 1);
    });
  });
}
