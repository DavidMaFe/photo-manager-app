import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../config/theme/app_palette.dart';
import 'app_button.dart';
import 'icon_circle_button.dart';

/// Header shown in selection mode: close, "N selected" and an All/None toggle.
class SelectionHeader extends StatelessWidget {
  final String title;

  /// Optional second line (e.g. «en Playa»).
  final String? subtitle;
  final String closeTooltip;
  final VoidCallback? onClose;
  final String toggleLabel;
  final VoidCallback? onToggle;

  const SelectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.closeTooltip,
    required this.onClose,
    required this.toggleLabel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 72),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            IconCircleButton(icon: Symbols.close_rounded, tooltip: closeTooltip, onPressed: onClose),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: context.palette.ink),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.palette.ink2),
                    ),
                ],
              ),
            ),
            AppButton.neutral(label: toggleLabel, size: AppButtonSize.small, onPressed: onToggle),
          ],
        ),
      ),
    );
  }
}
