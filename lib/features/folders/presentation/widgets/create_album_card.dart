import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/dashed_border.dart';

/// Dashed "create" card used as the last cell of album grids and rows.
class CreateAlbumCard extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double radius;
  final double iconSize;

  const CreateAlbumCard({
    super.key,
    required this.label,
    required this.onTap,
    this.radius = 22,
    this.iconSize = 28,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: DashedBorder(
            radius: radius,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.add_rounded, size: iconSize, color: p.accentInk),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: p.accentInk),
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
