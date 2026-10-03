import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';

/// Esqueleto de carga de rejillas: cuadrados surface2 con un brillo suave.
class MediaGridSkeleton extends StatefulWidget {
  final int itemCount;
  final int columns;
  final double radius;
  final double spacing;
  final EdgeInsetsGeometry padding;

  const MediaGridSkeleton({
    super.key,
    this.itemCount = 18,
    this.columns = 3,
    this.radius = AppRadius.thumb,
    this.spacing = AppSpacing.gridGap,
    this.padding = const EdgeInsets.fromLTRB(AppSpacing.gridGap, 54, AppSpacing.gridGap, AppSpacing.gridGap),
  });

  @override
  State<MediaGridSkeleton> createState() => _MediaGridSkeletonState();
}

class _MediaGridSkeletonState extends State<MediaGridSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: MaterialLocalizations.of(context).refreshIndicatorSemanticLabel,
      child: ExcludeSemantics(
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.55, end: 1).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
          ),
          child: GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: widget.padding,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: widget.columns,
              mainAxisSpacing: widget.spacing,
              crossAxisSpacing: widget.spacing,
            ),
            itemCount: widget.itemCount,
            itemBuilder: (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(widget.radius),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
