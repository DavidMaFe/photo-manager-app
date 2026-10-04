import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photo_manager_app/config/theme/app_colors.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/config/theme/app_theme.dart';
import 'package:photo_manager_app/config/theme/app_typography.dart';

void main() {
  group('AppTheme', () {
    group('light', () {
      test('should use the light palette and brand accent', () {
        // Arrange
        final theme = AppTheme.light();

        // Act
        final palette = theme.extension<AppPalette>();

        // Assert
        expect(theme.brightness, Brightness.light);
        expect(palette, AppPalette.light);
        expect(theme.colorScheme.primary, AppColors.accent);
        expect(theme.scaffoldBackgroundColor, AppColors.background);
      });

      test('should apply Plus Jakarta Sans and the typography roles', () {
        // Arrange
        final theme = AppTheme.light();

        // Act
        final title = theme.textTheme.headlineMedium!;
        final note = theme.textTheme.bodySmall!;

        // Assert
        expect(title.fontFamily, AppTypography.fontFamily);
        expect(title.fontSize, 30);
        expect(title.fontWeight, FontWeight.w800);
        expect(note.fontSize, 12);
        expect(note.color, AppColors.ink2);
      });
    });

    group('dark', () {
      test('should use the dark palette', () {
        // Arrange
        final theme = AppTheme.dark();

        // Act
        final palette = theme.extension<AppPalette>()!;

        // Assert
        expect(theme.brightness, Brightness.dark);
        expect(theme.colorScheme.primary, AppColors.darkAccent);
        expect(theme.scaffoldBackgroundColor, AppColors.darkBackground);
        expect(palette.dangerInk, AppColors.darkDanger);
        expect(palette.safe, AppPalette.light.safe);
      });
    });
  });

  group('AppPalette', () {
    group('lerp', () {
      test('should return start and end palettes at t=0 and t=1', () {
        // Arrange
        const light = AppPalette.light;
        const dark = AppPalette.dark;

        // Act
        final start = light.lerp(dark, 0);
        final end = light.lerp(dark, 1);

        // Assert
        expect(start.accent, light.accent);
        expect(end.accent, dark.accent);
        expect(end.background, dark.background);
      });
    });

    group('copyWith', () {
      test('should override only the given colors', () {
        // Arrange
        const palette = AppPalette.light;

        // Act
        final copy = palette.copyWith(accent: AppColors.danger);

        // Assert
        expect(copy.accent, AppColors.danger);
        expect(copy.ink, palette.ink);
      });
    });

    group('context.palette', () {
      testWidgets('should expose the palette of the current theme', (tester) async {
        // Arrange
        AppPalette? found;
        await tester.pumpWidget(MaterialApp(
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: ThemeMode.dark,
          home: Builder(builder: (context) {
            found = context.palette;
            return const SizedBox();
          }),
        ));

        // Assert
        expect(found, AppPalette.dark);
      });
    });
  });
}
