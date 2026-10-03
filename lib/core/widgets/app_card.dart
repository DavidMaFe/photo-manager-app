import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Tarjeta de «Revelado»: fondo surface, radio 22, sin sombra ni borde.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Color? color;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.onTap,
    this.onLongPress,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    final inner = Padding(padding: padding, child: child);

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: color ?? context.palette.surface,
        borderRadius: radius,
        clipBehavior: Clip.antiAlias,
        child: onTap == null && onLongPress == null
            ? inner
            : InkWell(onTap: onTap, onLongPress: onLongPress, child: inner),
      ),
    );
  }
}
