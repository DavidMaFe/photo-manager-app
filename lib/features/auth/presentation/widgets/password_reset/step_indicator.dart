import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';

/// Progress bars of a multi-step flow (completed in accent, pending in line).
class StepIndicator extends StatelessWidget {
  final int current;
  final int total;
  final String semanticLabel;

  const StepIndicator({
    super.key,
    required this.current,
    required this.total,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 1; i <= total; i++) ...[
            if (i > 1) const SizedBox(width: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 6,
              decoration: BoxDecoration(
                color: i <= current ? p.accent : p.line,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
          const SizedBox(width: 8),
        ],
      ),
    );
  }
}
