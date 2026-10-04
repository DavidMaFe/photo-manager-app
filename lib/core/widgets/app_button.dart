import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

enum AppButtonVariant {
  /// Fondo accent, texto blanco. Acción principal.
  primary,

  /// Fondo accentSoft, texto accentInk.
  secondary,

  /// Fondo surface2, texto ink.
  neutral,

  /// Fondo ink, texto claro («neutral oscuro», p. ej. «Revisar»).
  inverse,

  /// Transparente, texto ink.
  text,

  /// Fondo dangerSoft, texto dangerInk.
  danger,
}

enum AppButtonSize {
  /// Alto 54, radio 16.
  large,

  /// Alto 36, pastilla.
  small,
}

/// Botón de «Revelado». Sustituye a ElevatedButton/OutlinedButton con estilos sueltos.
class AppButton extends StatelessWidget {
  static const double largeHeight = 54;
  static const double smallHeight = 36;
  static const double disabledOpacity = 0.45;

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final IconData? icon;
  final bool loading;

  /// Ocupa todo el ancho disponible. Por defecto, sí en grande y no en pequeño.
  final bool? expand;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  });

  const AppButton.primary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  }) : variant = AppButtonVariant.primary;

  const AppButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  }) : variant = AppButtonVariant.secondary;

  const AppButton.neutral({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  }) : variant = AppButtonVariant.neutral;

  const AppButton.text({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  }) : variant = AppButtonVariant.text;

  const AppButton.danger({
    super.key,
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.large,
    this.icon,
    this.loading = false,
    this.expand,
  }) : variant = AppButtonVariant.danger;

  bool get _isLarge => size == AppButtonSize.large;
  bool get _enabled => onPressed != null && !loading;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = colorsFor(context, variant);
    final radius = BorderRadius.circular(_isLarge ? AppRadius.button : AppRadius.pill);
    final textStyle = TextStyle(
      fontSize: _isLarge ? 15 : 13,
      fontWeight: FontWeight.w700,
      color: foreground,
    );

    final content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: _isLarge ? 20 : 18, color: foreground),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  label,
                  style: textStyle,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          );

    final button = Semantics(
      button: true,
      enabled: _enabled,
      child: Opacity(
        opacity: onPressed == null ? disabledOpacity : 1,
        child: Material(
          color: background,
          borderRadius: radius,
          child: InkWell(
            onTap: _enabled ? onPressed : null,
            borderRadius: radius,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: _isLarge ? largeHeight : smallHeight),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: _isLarge ? 20 : 14, vertical: 8),
                child: Center(widthFactor: 1, heightFactor: 1, child: content),
              ),
            ),
          ),
        ),
      ),
    );

    final shouldExpand = expand ?? _isLarge;
    return shouldExpand ? SizedBox(width: double.infinity, child: button) : button;
  }

  /// Colores (fondo, primer plano) de cada variante.
  static (Color, Color) colorsFor(BuildContext context, AppButtonVariant variant) {
    final p = context.palette;
    final onAccent = Theme.of(context).colorScheme.onPrimary;
    return switch (variant) {
      AppButtonVariant.primary => (p.accent, onAccent),
      AppButtonVariant.secondary => (p.accentSoft, p.accentInk),
      AppButtonVariant.neutral => (p.surface2, p.ink),
      AppButtonVariant.inverse => (p.ink, p.surface),
      AppButtonVariant.text => (p.surface.withValues(alpha: 0), p.ink),
      AppButtonVariant.danger => (p.dangerSoft, p.dangerInk),
    };
  }
}
