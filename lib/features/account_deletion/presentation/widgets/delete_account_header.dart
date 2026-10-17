import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/auth/presentation/widgets/password_reset/step_indicator.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Top bar of the deletion steps: back and the red step bars.
class DeleteAccountTopBar extends StatelessWidget implements PreferredSizeWidget {
  final int step;
  final VoidCallback onBack;

  const DeleteAccountTopBar({super.key, required this.step, required this.onBack});

  @override
  Size get preferredSize => const Size.fromHeight(SecondaryTopBar.height);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return SecondaryTopBar(
      onBack: onBack,
      backgroundColor: p.background,
      actions: [
        StepIndicator(
          current: step,
          total: 2,
          activeColor: p.danger,
          semanticLabel: l10n.deleteAccountStep(step, 2),
        ),
      ],
    );
  }
}

/// «Step n of 2», the title and the subtitle of a deletion step, with the red icon on the first one.
class DeleteAccountHeading extends StatelessWidget {
  final int step;
  final String title;
  final Widget subtitle;
  final bool showIcon;

  const DeleteAccountHeading({
    super.key,
    required this.step,
    required this.title,
    required this.subtitle,
    this.showIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showIcon) ...[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: p.dangerSoft, borderRadius: BorderRadius.circular(16)),
            child: Icon(Symbols.person_remove_rounded, size: 28, color: p.dangerInk),
          ),
          const SizedBox(height: 16),
        ],
        Text(l10n.deleteAccountStep(step, 2),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink2)),
        const SizedBox(height: 4),
        Semantics(
          header: true,
          child: Text(title, style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, height: 1.15, color: p.ink)),
        ),
        const SizedBox(height: 8),
        DefaultTextStyle.merge(style: TextStyle(fontSize: 15, color: p.ink2), child: subtitle),
      ],
    );
  }
}
