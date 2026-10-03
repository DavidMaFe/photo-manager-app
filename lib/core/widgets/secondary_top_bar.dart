import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_typography.dart';
import 'icon_circle_button.dart';

/// Barra superior de pantallas secundarias: volver + título 18/w800 + acciones.
///
/// Se puede usar como `Scaffold.appBar` (añade el safe area superior).
class SecondaryTopBar extends StatelessWidget implements PreferredSizeWidget {
  static const double height = 64;

  final String? title;
  final List<Widget> actions;
  final bool showBack;

  /// Por defecto, `Navigator.maybePop`.
  final VoidCallback? onBack;

  /// Por defecto, `background`. Usar `surface` en pantallas con fondo blanco.
  final Color? backgroundColor;

  const SecondaryTopBar({
    super.key,
    this.title,
    this.actions = const [],
    this.showBack = true,
    this.onBack,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Material(
      color: backgroundColor ?? p.background,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: height,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (showBack)
                  IconCircleButton(
                    icon: Symbols.arrow_back_rounded,
                    tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                if (showBack && title != null) const SizedBox(width: 12),
                Expanded(
                  child: title == null
                      ? const SizedBox.shrink()
                      : Semantics(
                          header: true,
                          child: Text(
                            title!,
                            style: AppTypography.secondaryBarTitle(p),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                ),
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions[i],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
