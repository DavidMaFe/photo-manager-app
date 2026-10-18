import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_layout.dart';

import '../../../helpers/widget_test_helper.dart' show setUpCustomScreenSize;

void main() {
  late List<MethodCall> systemCalls;

  setUp(() {
    systemCalls = [];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method.startsWith('SystemChrome.setEnabledSystemUI')) systemCalls.add(call);
        return null;
      },
    );
  });

  tearDown(() => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(SystemChannels.platform, null));

  const media = ColoredBox(key: ValueKey('media'), color: Colors.green);

  Widget layout({required bool visible}) => MaterialApp(
        home: Scaffold(
          body: MediaViewerLayout(
            chromeVisible: visible,
            media: media,
            top: const SizedBox(key: ValueKey('top'), height: 100),
            bottom: const SizedBox(key: ValueKey('bottom'), height: 150),
          ),
        ),
      );

  Future<void> pump(WidgetTester tester, {required bool visible}) async {
    setUpCustomScreenSize(tester, 400, 800);
    await tester.pumpWidget(layout(visible: visible));
    await tester.pumpAndSettle();
  }

  Rect mediaRect(WidgetTester tester) => tester.getRect(find.byKey(const ValueKey('media')));

  bool ignored(WidgetTester tester, String key) => tester
      .widget<IgnorePointer>(find.ancestor(of: find.byKey(ValueKey(key)), matching: find.byType(IgnorePointer)).first)
      .ignoring;

  group('MediaViewerLayout', () {
    testWidgets('should fit the media between the top chrome and the bottom panel', (tester) async {
      // Arrange & Act
      await pump(tester, visible: true);

      // Assert
      expect(mediaRect(tester), const Rect.fromLTRB(0, 100, 400, 650));
      expect(ignored(tester, 'top'), isFalse);
      expect(ignored(tester, 'bottom'), isFalse);
    });

    testWidgets('should take its space at once when the viewer opens', (tester) async {
      // Arrange
      setUpCustomScreenSize(tester, 400, 800);
      await tester.pumpWidget(layout(visible: true));

      // Act: the chrome is measured in the first frame and applied in the next ones, without the animation
      await tester.pump();
      await tester.pump();

      // Assert
      expect(mediaRect(tester), const Rect.fromLTRB(0, 100, 400, 650));
    });

    testWidgets('should grow the media to the full screen when the chrome hides', (tester) async {
      // Arrange
      await pump(tester, visible: true);

      // Act
      await tester.pumpWidget(layout(visible: false));
      await tester.pump(MediaViewerLayout.duration ~/ 2);
      final halfway = mediaRect(tester);
      await tester.pumpAndSettle();

      // Assert: animated, from its space to the full screen
      expect(halfway.top, inExclusiveRange(0, 100));
      expect(mediaRect(tester), const Rect.fromLTRB(0, 0, 400, 800));
    });

    testWidgets('should slide the chrome out of the screen and let taps through it', (tester) async {
      // Arrange
      await pump(tester, visible: true);

      // Act
      await tester.pumpWidget(layout(visible: false));
      await tester.pumpAndSettle();

      // Assert
      expect(tester.getRect(find.byKey(const ValueKey('top'))).bottom, lessThanOrEqualTo(0));
      expect(tester.getRect(find.byKey(const ValueKey('bottom'))).top, greaterThanOrEqualTo(800));
      expect(ignored(tester, 'top'), isTrue);
      expect(ignored(tester, 'bottom'), isTrue);
    });

    testWidgets('should give the media its space back when the chrome shows again', (tester) async {
      // Arrange
      await pump(tester, visible: true);
      await tester.pumpWidget(layout(visible: false));
      await tester.pumpAndSettle();

      // Act
      await tester.pumpWidget(layout(visible: true));
      await tester.pumpAndSettle();

      // Assert
      expect(mediaRect(tester), const Rect.fromLTRB(0, 100, 400, 650));
    });

    testWidgets('should hide the status bar in full screen and bring it back with the chrome', (tester) async {
      // Arrange
      await pump(tester, visible: true);

      // Act & Assert: full screen, no system bar
      await tester.pumpWidget(layout(visible: false));
      expect(systemCalls.last.method, 'SystemChrome.setEnabledSystemUIOverlays');
      expect(systemCalls.last.arguments, isEmpty);

      // Act & Assert: back to the mode of the app
      await tester.pumpWidget(layout(visible: true));
      expect(systemCalls.last.method, 'SystemChrome.setEnabledSystemUIMode');
      expect(systemCalls.last.arguments, 'SystemUiMode.immersiveSticky');
    });

    testWidgets('should bring the status bar back when the viewer closes in full screen', (tester) async {
      // Arrange
      await pump(tester, visible: false);
      systemCalls.clear();

      // Act
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Assert
      expect(systemCalls.single.arguments, 'SystemUiMode.immersiveSticky');
    });
  });
}
