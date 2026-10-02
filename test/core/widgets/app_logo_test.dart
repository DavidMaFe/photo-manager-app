import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_theme.dart';
import 'package:photo_manager_app/core/widgets/app_logo.dart';

void main() {
  Widget wrap(Widget child, {ThemeMode mode = ThemeMode.light}) {
    return MaterialApp(
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: mode,
      home: Scaffold(body: Center(child: child)),
    );
  }

  String markAssetOf(WidgetTester tester) {
    final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
    return (svg.bytesLoader as SvgAssetLoader).assetName;
  }

  /// Leaf spans of the wordmark ("Photo", "Manager").
  List<TextSpan> wordmarkSpans(WidgetTester tester) {
    final text = tester.widget<RichText>(
      find.byWidgetPredicate((w) => w is RichText && w.text.toPlainText() == 'PhotoManager'),
    );
    final leaves = <TextSpan>[];
    text.text.visitChildren((span) {
      if (span is TextSpan && span.text != null) leaves.add(span);
      return true;
    });
    return leaves;
  }

  group('AppLogo', () {
    group('mark asset', () {
      testWidgets('should use the light mark on a light theme', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(markHeight: 72)));

        // Act
        final asset = markAssetOf(tester);

        // Assert
        expect(asset, AppLogo.markAsset);
      });

      testWidgets('should use the dark mark on a dark theme', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(markHeight: 72), mode: ThemeMode.dark));

        // Act
        final asset = markAssetOf(tester);

        // Assert
        expect(asset, AppLogo.markDarkAsset);
      });

      testWidgets('should use the white mark on the accent variant', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrap(const AppLogo(markHeight: 72, variant: AppLogoVariant.onAccent)),
        );

        // Act
        final asset = markAssetOf(tester);

        // Assert
        expect(asset, AppLogo.markWhiteAsset);
      });

      testWidgets('should use the small mark below 32 px', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(markHeight: 24)));

        // Act
        final asset = markAssetOf(tester);

        // Assert
        expect(asset, AppLogo.markSmallAsset);
      });

      testWidgets('should keep the mark aspect ratio', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(markHeight: 56, showWordmark: false)));

        // Act
        final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));

        // Assert
        expect(svg.height, 56);
        expect(svg.width, 78);
      });
    });

    group('wordmark', () {
      testWidgets('should show Photo in ink and Manager in accent', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo()));

        // Act
        final spans = wordmarkSpans(tester);

        // Assert
        expect(spans[0].text, 'Photo');
        expect(spans[0].style!.color, AppPalette.light.ink);
        expect(spans[1].text, 'Manager');
        expect(spans[1].style!.color, AppPalette.light.accent);
      });

      testWidgets('should render the wordmark in white on the accent variant', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(variant: AppLogoVariant.onAccent)));

        // Act
        final spans = wordmarkSpans(tester);

        // Assert
        expect(spans.map((s) => s.style!.color), everyElement(Colors.white));
      });

      testWidgets('should hide the wordmark when showWordmark is false', (tester) async {
        // Arrange
        await tester.pumpWidget(wrap(const AppLogo(showWordmark: false)));

        // Assert
        expect(find.textContaining('Photo'), findsNothing);
        expect(find.bySemanticsLabel('Photo Manager'), findsOneWidget);
      });

      testWidgets('should stack the wordmark below the mark when vertical', (tester) async {
        // Arrange
        await tester.pumpWidget(
          wrap(const AppLogo(markHeight: 72, direction: Axis.vertical)),
        );

        // Act
        final markBox = tester.getRect(find.byType(SvgPicture));
        final textBox = tester.getRect(find.byType(RichText).last);

        // Assert
        expect(find.byType(Column), findsWidgets);
        expect(textBox.top, greaterThanOrEqualTo(markBox.bottom));
      });
    });
  });
}
