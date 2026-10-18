import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';

import '../../../helpers/widget_test_helper.dart';

void main() {
  Future<AppPalette> pump(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(makeTestableWidget(Scaffold(body: Align(alignment: Alignment.bottomCenter, child: child))));
    return tester.element(find.byWidget(child)).palette;
  }

  Color labelColor(WidgetTester tester, String label) => tester.widget<Text>(find.text(label)).style!.color!;

  MediaViewerActionBar bar(List<Widget> actions) => MediaViewerActionBar(
        children: [for (final action in actions) Expanded(child: action)],
      );

  group('MediaViewerBottomPanel', () {
    testWidgets('should sit on the black of the viewer with a hairline above', (tester) async {
      // Arrange & Act
      final p = await pump(tester, MediaViewerBottomPanel(actions: bar([
        MediaViewerAction(icon: Symbols.ios_share_rounded, label: 'Share', onPressed: () {}),
      ])));

      // Assert
      final decoration = tester.widget<DecoratedBox>(
        find.descendant(of: find.byType(MediaViewerBottomPanel), matching: find.byType(DecoratedBox)).first,
      ).decoration as BoxDecoration;
      expect(decoration.color, p.media);
      expect((decoration.border! as Border).top.color, p.mediaChromeRaised);
      expect(decoration.borderRadius, isNull);
    });

    testWidgets('should show the strip above the actions', (tester) async {
      // Arrange & Act
      await pump(tester, MediaViewerBottomPanel(
        strip: const SizedBox(key: ValueKey('strip'), height: 46),
        actions: bar([MediaViewerAction(icon: Symbols.ios_share_rounded, label: 'Share', onPressed: () {})]),
      ));

      // Assert
      final strip = tester.getTopLeft(find.byKey(const ValueKey('strip')));
      expect(strip.dy, lessThan(tester.getTopLeft(find.text('Share')).dy));
    });
  });

  group('MediaViewerAction', () {
    testWidgets('should show the main action in the accent of the viewer, without a pill', (tester) async {
      // Arrange & Act
      final p = await pump(tester, bar([
        MediaViewerAction(icon: Symbols.restore_rounded, label: 'Restore', highlighted: true, onPressed: () {}),
        MediaViewerAction(icon: Symbols.ios_share_rounded, label: 'Share', onPressed: () {}),
      ]));

      // Assert
      expect(labelColor(tester, 'Restore'), p.mediaAccent);
      expect(labelColor(tester, 'Share'), p.onMedia);
    });
  });

  group('MediaViewerCoverAction', () {
    testWidgets('should be in the accent of the viewer when the photo is a cover', (tester) async {
      final p = await pump(tester, bar([MediaViewerCoverAction(label: 'Cover', isCover: true, onPressed: () {})]));
      expect(labelColor(tester, 'Cover'), p.mediaAccent);
      expect(tester.widget<Icon>(find.byType(Icon)).fill, 1);
    });

    testWidgets('should be white when the photo is no cover', (tester) async {
      final p = await pump(tester, bar([MediaViewerCoverAction(label: 'Cover', onPressed: () {})]));
      expect(labelColor(tester, 'Cover'), p.onMedia);
      expect(tester.widget<Icon>(find.byType(Icon)).fill, 0);
    });
  });
}
