import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';
import '../../config/theme/app_spacing.dart';

/// Esqueleto de carga de rejillas: cuadrados surface2 con un brillo suave.
class MediaGridSkeleton extends StatefulWidget {
  final int itemCount;

  const MediaGridSkeleton({super.key, this.itemCount = 18});

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
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.gridGap, 54, AppSpacing.gridGap, AppSpacing.gridGap),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: AppSpacing.gridGap,
              crossAxisSpacing: AppSpacing.gridGap,
            ),
            itemCount: widget.itemCount,
            itemBuilder: (_, __) => DecoratedBox(
              decoration: BoxDecoration(
                color: p.surface2,
                borderRadius: BorderRadius.circular(AppRadius.thumb),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
