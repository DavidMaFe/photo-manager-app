import 'dart:ui';

import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_typography.dart';

/// Destino de [AppNavBar].
class AppNavDestination {
  final IconData icon;
  final String label;

  const AppNavDestination({required this.icon, required this.label});
}

/// Barra de navegación inferior flotante.
///
/// El contenido de cada pestaña debe reservar [contentBottomPadding] abajo
/// para no quedar tapado.
class AppNavBar extends StatelessWidget {
  static const double height = 68;
  static const double margin = 16;
  static const double contentBottomPadding = 100;

  final List<AppNavDestination> destinations;
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppNavBar({
    super.key,
    required this.destinations,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final radius = BorderRadius.circular(24);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(margin, 0, margin, margin + bottomInset),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [BoxShadow(color: p.shadow, blurRadius: 24, offset: const Offset(0, 8))],
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              constraints: const BoxConstraints(minHeight: height),
              decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.94),
                borderRadius: radius,
                border: Border.all(color: p.shadowSoft),
              ),
              child: Row(
                children: [
                  for (var i = 0; i < destinations.length; i++)
                    Expanded(
                      child: _NavItem(
                        destination: destinations[i],
                        active: i == currentIndex,
                        onTap: () => onTap(i),
                      ),
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

class _NavItem extends StatelessWidget {
  final AppNavDestination destination;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.destination, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final color = active ? p.accentInk : p.ink2;

    return Semantics(
      button: true,
      selected: active,
      label: destination.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        radius: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                  color: active ? p.accentSoft : p.accentSoft.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(destination.icon, size: 22, color: color, fill: active ? 1 : 0),
              ),
              const SizedBox(height: 4),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.navLabel(p, active: active),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
