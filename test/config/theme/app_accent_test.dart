import 'dart:math' as math;

import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_accent.dart';
import 'package:photo_manager_app/config/theme/app_colors.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';

/// WCAG contrast ratio between two opaque colors.
double contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// [color] with its alpha over the opaque [background].
Color over(Color color, Color background) => Color.alphaBlend(color, background);

/// Distance between two hues, in degrees.
double hueDistance(Color a, Color b) {
  final d = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs();
  return math.min(d, 360 - d);
}

void main() {
  const white = Color(0xFFFFFFFF);
  const black = Color(0xFF000000);

  group('AppAccent', () {
    test('should offer violet, blue, teal, terracotta and graphite, violet by default', () {
      expect(AppAccent.values.map((accent) => accent.name), ['violet', 'blue', 'teal', 'terracotta', 'graphite']);
      expect(AppAccent.defaultAccent, AppAccent.violet);
    });

    test('should keep the current violet as the default family', () {
      final c = AppAccent.violet.colors;
      expect(c.accent, AppColors.accent);
      expect(c.darkAccent, AppColors.darkAccent);
      expect(c.mediaAccent, AppColors.mediaAccent);
    });

    group('fromName', () {
      test('should read a stored color', () => expect(AppAccent.fromName('teal'), AppAccent.teal));

      test('should fall back to violet for a missing or unknown color', () {
        expect(AppAccent.fromName(null), AppAccent.violet);
        expect(AppAccent.fromName('pink'), AppAccent.violet);
      });
    });

    for (final accent in AppAccent.values) {
      group('${accent.name} in the light theme', () {
        final c = accent.colors;

        test('should keep white text readable on the accent (AA)', () {
          expect(contrast(white, c.accent), greaterThanOrEqualTo(4.5));
        });

        test('should keep the accent text readable on the background and on the soft accent (AA)', () {
          expect(contrast(c.accentInk, AppColors.background), greaterThanOrEqualTo(4.5));
          expect(contrast(c.accentInk, AppColors.surface), greaterThanOrEqualTo(4.5));
          expect(contrast(c.accentInk, c.accentSoft), greaterThanOrEqualTo(4.5));
        });
      });

      group('${accent.name} in the dark theme', () {
        final c = accent.colors;

        test('should keep white text on the accent at least as readable as the violet', () {
          expect(contrast(white, c.darkAccent), greaterThanOrEqualTo(2.99));
        });

        test('should keep the accent readable on the background (AA)', () {
          expect(contrast(c.darkAccent, AppColors.darkBackground), greaterThanOrEqualTo(4.5));
          expect(contrast(c.darkAccent, AppColors.darkSurface), greaterThanOrEqualTo(4.5));
          expect(contrast(c.darkAccentInk, c.darkAccentSoft), greaterThanOrEqualTo(4.5));
        });
      });

      test('should keep ${accent.name} readable on the black viewer (AAA)', () {
        final c = accent.colors;
        expect(contrast(c.mediaAccent, black), greaterThanOrEqualTo(7));
        expect(contrast(c.mediaCover, over(c.mediaCoverSoft, black)), greaterThanOrEqualTo(7));
      });
    }

    test('should not look like the colors with a meaning (safe, review, delete, favorite)', () {
      const states = [AppColors.safe, AppColors.review, AppColors.danger, AppColors.favorite];
      for (final accent in AppAccent.values.where((accent) => accent != AppAccent.graphite)) {
        for (final state in states) {
          expect(hueDistance(accent.colors.accent, state), greaterThanOrEqualTo(14),
              reason: '${accent.name} vs ${state.toARGB32().toRadixString(16)}');
        }
      }
    });
  });

  group('AppPalette', () {
    test('should take the accent of the chosen color in each theme', () {
      final light = AppPalette.lightFor(AppAccent.teal);
      final dark = AppPalette.darkFor(AppAccent.teal);
      final c = AppAccent.teal.colors;

      expect([light.accent, light.accentInk, light.accentSoft], [c.accent, c.accentInk, c.accentSoft]);
      expect([dark.accent, dark.accentInk, dark.accentSoft], [c.darkAccent, c.darkAccentInk, c.darkAccentSoft]);
      expect([light.mediaAccent, light.mediaCover, dark.mediaAccent], [c.mediaAccent, c.mediaCover, c.mediaAccent]);
    });

    test('should keep the brand violet and the colors with a meaning whatever the color', () {
      final palette = AppPalette.lightFor(AppAccent.terracotta);

      expect(palette.brand, AppColors.accent);
      expect(AppPalette.darkFor(AppAccent.terracotta).brand, AppColors.darkAccent);
      expect([palette.safe, palette.review, palette.danger, palette.favorite],
          [AppColors.safe, AppColors.review, AppColors.danger, AppColors.favorite]);
    });

    test('should be the current violet palette by default', () {
      expect(AppPalette.lightFor(AppAccent.violet).accent, AppPalette.light.accent);
      expect(AppPalette.darkFor(AppAccent.violet).accentSoft, AppPalette.dark.accentSoft);
    });
  });
}
