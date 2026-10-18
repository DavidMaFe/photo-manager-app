import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';
import 'app_context_menu.dart';

enum SelectionActionStyle {
  /// Accent background (main action).
  primary,

  /// Raised dark background.
  neutral,

  /// Light red text on the dark background.
  danger,
}

/// Option of the menu of a [SelectionAction] («More»).
class SelectionMenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool destructive;

  const SelectionMenuItem({required this.icon, required this.label, required this.onSelected, this.destructive = false});
}

/// Action of [SelectionActionBar].
class SelectionAction {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final SelectionActionStyle style;

  /// Icon fill (1 = filled); the icon's default when `null`.
  final double? iconFill;

  /// Looks disabled but still reacts (e.g. to explain why it is not available).
  final bool dimmed;

  /// Options shown in a menu above the button when it is tapped (then [onPressed] only enables it).
  final List<SelectionMenuItem>? menu;

  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.style = SelectionActionStyle.neutral,
    this.iconFill,
    this.dimmed = false,
    this.menu,
  });
}

/// Floating bar shown in selection mode instead of the navigation bar: one action per column, icon over label. The
/// main action has its icon in an accent pill; [label] is an optional line above the actions (e.g. the cover limit).
class SelectionActionBar extends StatelessWidget {
  final String? label;
  final List<SelectionAction> actions;

  const SelectionActionBar({super.key, this.label, required this.actions});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: p.lineSoft),
          boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (label != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 2, 8, 6),
                  child: Text(
                    label!,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                  ),
                ),
              Row(
                children: [
                  for (final action in actions) Expanded(child: _ActionButton(action: action)),
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
    final (iconColor, labelColor) = switch (action.style) {
      SelectionActionStyle.primary => (p.onAccent, p.accent),
      SelectionActionStyle.neutral => (p.ink, p.ink),
      SelectionActionStyle.danger => (p.danger, p.danger),
    };
    final radius = BorderRadius.circular(AppRadius.button);

    return Opacity(
      opacity: action.onPressed == null || action.dimmed ? 0.45 : 1,
      child: Material(
        color: p.surface.withValues(alpha: 0),
        borderRadius: radius,
        child: InkWell(
          onTap: action.onPressed == null
              ? null
              : action.menu == null
                  ? action.onPressed
                  : () => _openMenu(context, action.menu!),
          borderRadius: radius,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52,
                    height: 30,
                    decoration: action.style == SelectionActionStyle.primary
                        ? BoxDecoration(color: p.accent, borderRadius: BorderRadius.circular(AppRadius.pill))
                        : null,
                    child: Icon(action.icon, size: 22, color: iconColor, fill: action.iconFill),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: labelColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openMenu(BuildContext context, List<SelectionMenuItem> items) async {
    final box = context.findRenderObject() as RenderBox;
    final selected = await showAppContextMenu<SelectionMenuItem>(
      context,
      position: box.localToGlobal(box.size.topRight(Offset.zero)),
      items: [
        for (final item in items)
          AppMenuItem(value: item, label: item.label, icon: item.icon, destructive: item.destructive),
      ],
    );
    selected?.onSelected();
  }
}
