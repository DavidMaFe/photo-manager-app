import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

enum StatusChipVariant { safe, review, danger, neutral, accent }

/// Pastilla de estado: icono 18 + texto 13/w700 sobre el color *Soft* del estado.
class StatusChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final StatusChipVariant variant;

  /// Alto 30 en vez de 36.
  final bool compact;
  final VoidCallback? onTap;

  const StatusChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = StatusChipVariant.neutral,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = colorsFor(context.palette, variant);
    final radius = BorderRadius.circular(AppRadius.pill);

    final content = ConstrainedBox(
      constraints: BoxConstraints(minHeight: compact ? 30 : 36),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 16 : 18, color: foreground),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );

    return Material(
      color: background,
      borderRadius: radius,
      child: onTap == null
          ? content
          : InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }

  static (Color, Color) colorsFor(AppPalette p, StatusChipVariant variant) {
    return switch (variant) {
      StatusChipVariant.safe => (p.safeSoft, p.safeInk),
      StatusChipVariant.review => (p.reviewSoft, p.reviewInk),
      StatusChipVariant.danger => (p.dangerSoft, p.dangerInk),
      StatusChipVariant.neutral => (p.surface2, p.ink),
      StatusChipVariant.accent => (p.accentSoft, p.accentInk),
    };
  }
}
