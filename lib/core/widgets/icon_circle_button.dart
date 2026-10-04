import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';

/// Botón de icono circular 44×44 (volver, compartir, más opciones).
class IconCircleButton extends StatelessWidget {
  static const double defaultSize = 44;

  /// Diámetro del círculo. Por debajo de 44 conviene envolverlo en un área táctil de 44.
  final double size;

  final IconData icon;
  final VoidCallback? onPressed;

  /// Obligatorio: los botones solo de icono necesitan texto accesible.
  final String tooltip;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double iconSize;

  const IconCircleButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.iconSize = 22,
    this.size = defaultSize,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: _withTouchTarget(
          Material(
            color: backgroundColor ?? p.surface2,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onPressed,
              child: SizedBox.square(
                dimension: size,
                child: Icon(icon, size: iconSize, color: foregroundColor ?? p.ink),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Small circles keep a 44 px touch target around them.
  Widget _withTouchTarget(Widget circle) {
    if (size >= defaultSize) return circle;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox.square(dimension: defaultSize, child: Center(child: circle)),
    );
  }
}
