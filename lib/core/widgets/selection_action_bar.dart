import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

enum SelectionActionStyle {
  /// Accent background (main action).
  primary,

  /// Raised dark background.
  neutral,

  /// Light red text on the dark background.
  danger,
}

/// Action of [SelectionActionBar].
class SelectionAction {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final SelectionActionStyle style;

  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = SelectionActionStyle.neutral,
  });
}

/// Floating dark bar shown in selection mode instead of the navigation bar:
/// a count line and one button per action.
class SelectionActionBar extends StatelessWidget {
  final String label;
  final List<SelectionAction> actions;

  const SelectionActionBar({super.key, required this.label, required this.actions});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.mediaChrome,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.onMediaMuted),
                ),
              ),
              Row(
                children: [
                  for (var i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _ActionButton(action: actions[i])),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final SelectionAction action;

  const _ActionButton({required this.action});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (background, foreground) = switch (action.style) {
      SelectionActionStyle.primary => (p.accent, p.onAccent),
      SelectionActionStyle.neutral => (p.mediaChromeRaised, p.onMedia),
      SelectionActionStyle.danger => (p.mediaChromeRaised, p.mediaDanger),
    };
    final radius = BorderRadius.circular(AppRadius.button);

    return Opacity(
      opacity: action.onPressed == null ? 0.45 : 1,
      child: Material(
        color: background,
        borderRadius: radius,
        child: InkWell(
          onTap: action.onPressed,
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(action.icon, size: 22, color: foreground),
                  const SizedBox(height: 4),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
