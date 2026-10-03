import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Appearance sheet: automatic, light or dark theme.
class ThemeModeSheet extends StatelessWidget {
  final ThemeMode selected;

  const ThemeModeSheet({super.key, required this.selected});

  /// Returns the chosen mode, or `null` if the sheet was dismissed.
  static Future<ThemeMode?> show(BuildContext context, {required ThemeMode selected}) {
    return showAppSheet<ThemeMode>(context, builder: (_) => ThemeModeSheet(selected: selected));
  }

  static String labelOf(ThemeMode mode, AppLocalizations l10n) {
    return switch (mode) {
      ThemeMode.system => l10n.themeSystem,
      ThemeMode.light => l10n.themeLight,
      ThemeMode.dark => l10n.themeDark,
    };
  }

  static IconData _iconOf(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.system => Symbols.brightness_auto_rounded,
      ThemeMode.light => Symbols.light_mode_rounded,
      ThemeMode.dark => Symbols.dark_mode_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.appearance, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        ListRowGroup(
          children: [
            for (final mode in const [ThemeMode.system, ThemeMode.light, ThemeMode.dark])
              Semantics(
                selected: mode == selected,
                inMutuallyExclusiveGroup: true,
                child: ListRow(
                  icon: _iconOf(mode),
                  title: labelOf(mode, l10n),
                  subtitle: mode == ThemeMode.system ? l10n.themeSystemHint : null,
                  trailing: mode == selected
                      ? Icon(Symbols.check_circle_rounded, fill: 1, size: 22, color: p.accent)
                      : const SizedBox(width: 22),
                  onTap: () => Navigator.pop(context, mode),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
