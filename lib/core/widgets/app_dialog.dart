import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import 'app_button.dart';

/// Tono del icono del diálogo (fondo *Soft* + icono del color del estado).
enum AppDialogTone { accent, safe, review, danger, neutral }

/// Diálogo único de «Revelado».
///
/// [show] devuelve `true` al pulsar la acción principal, `false` al pulsar la
/// secundaria y `null` si se cierra tocando fuera.
class AppDialog extends StatelessWidget {
  final IconData? icon;
  final AppDialogTone tone;
  final String title;
  final String? message;

  /// Contenido extra bajo el mensaje (p. ej. una casilla «No volver a mostrar»).
  final Widget? content;
  final String primaryLabel;
  final String? secondaryLabel;

  /// La acción principal es destructiva (botón en variante danger).
  final bool destructive;
  final VoidCallback? onPrimary;
  final VoidCallback? onSecondary;

  const AppDialog({
    super.key,
    this.icon,
    this.tone = AppDialogTone.accent,
    required this.title,
    this.message,
    this.content,
    required this.primaryLabel,
    this.secondaryLabel,
    this.destructive = false,
    this.onPrimary,
    this.onSecondary,
  });

  static Future<bool?> show({
    required BuildContext context,
    IconData? icon,
    AppDialogTone tone = AppDialogTone.accent,
    required String title,
    String? message,
    Widget? content,
    required String primaryLabel,
    String? secondaryLabel,
    bool destructive = false,
    VoidCallback? onPrimary,
    VoidCallback? onSecondary,
    bool barrierDismissible = true,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (_) => AppDialog(
        icon: icon,
        tone: tone,
        title: title,
        message: message,
        content: content,
        primaryLabel: primaryLabel,
        secondaryLabel: secondaryLabel,
        destructive: destructive,
        onPrimary: onPrimary,
        onSecondary: onSecondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final (iconBackground, iconColor) = toneColors(p, tone);
    final hasSecondary = secondaryLabel != null && secondaryLabel!.isNotEmpty;

    final primary = AppButton(
      label: primaryLabel,
      variant: destructive ? AppButtonVariant.danger : AppButtonVariant.primary,
      onPressed: () {
        Navigator.of(context).pop(true);
        onPrimary?.call();
      },
    );

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(color: iconBackground, shape: BoxShape.circle),
                  child: Icon(icon, size: 24, color: iconColor),
                ),
                const SizedBox(height: 16),
              ],
              Semantics(
                header: true,
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink),
                ),
              ),
              if (message != null && message!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  message!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: p.ink2,
                  ),
                ),
              ],
              if (content != null) ...[const SizedBox(height: 16), content!],
              const SizedBox(height: 24),
              if (hasSecondary)
                Row(
                  children: [
                    Expanded(
                      child: AppButton.neutral(
                        label: secondaryLabel!,
                        onPressed: () {
                          Navigator.of(context).pop(false);
                          onSecondary?.call();
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: primary),
                  ],
                )
              else
                primary,
            ],
          ),
        ),
      ),
    );
  }

  static (Color, Color) toneColors(AppPalette p, AppDialogTone tone) {
    return switch (tone) {
      AppDialogTone.accent => (p.accentSoft, p.accentInk),
      AppDialogTone.safe => (p.safeSoft, p.safe),
      AppDialogTone.review => (p.reviewSoft, p.reviewIcon),
      AppDialogTone.danger => (p.dangerSoft, p.danger),
      AppDialogTone.neutral => (p.surface2, p.ink2),
    };
  }
}
