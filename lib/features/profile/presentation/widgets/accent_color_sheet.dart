import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_accent.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Color of the app: the five colors as swatches. A tap applies the color at once (the sheet and the app behind it
/// change), and the sheet stays open to try another one.
class AccentColorSheet extends StatelessWidget {
  final ValueListenable<AppAccent> accent;
  final ValueChanged<AppAccent> onChanged;

  const AccentColorSheet({super.key, required this.accent, required this.onChanged});

  static Future<void> show(
    BuildContext context, {
    required ValueListenable<AppAccent> accent,
    required ValueChanged<AppAccent> onChanged,
  }) {
    return showAppSheet<void>(context, builder: (_) => AccentColorSheet(accent: accent, onChanged: onChanged));
  }

  static String labelOf(AppAccent accent, AppLocalizations l10n) {
    return switch (accent) {
      AppAccent.violet => l10n.accentViolet,
      AppAccent.blue => l10n.accentBlue,
      AppAccent.teal => l10n.accentTeal,
      AppAccent.terracotta => l10n.accentTerracotta,
      AppAccent.graphite => l10n.accentGraphite,
    };
  }

  /// The color of [accent] in the current theme (light or dark).
  static Color swatchOf(BuildContext context, AppAccent accent) =>
      Theme.of(context).brightness == Brightness.dark ? accent.colors.darkAccent : accent.colors.accent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.appColor, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 6),
        Text(l10n.appColorHint, style: TextStyle(fontSize: 14, color: p.ink2)),
        const SizedBox(height: 20),
        ValueListenableBuilder<AppAccent>(
          valueListenable: accent,
          builder: (context, selected, _) => Row(
            children: [
              for (final option in AppAccent.values)
                Expanded(
                  child: _Swatch(
                    color: swatchOf(context, option),
                    label: labelOf(option, l10n),
                    selected: option == selected,
                    onTap: () => onChanged(option),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _Swatch({required this.color, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: selected ? color : p.background.withValues(alpha: 0), width: 2.5),
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  child: selected
                      ? Icon(Symbols.check_rounded, size: 24, weight: 700, color: p.onAccent)
                      : const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? p.ink : p.ink2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
