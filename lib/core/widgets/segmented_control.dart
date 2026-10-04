import 'package:flutter/material.dart';

import '../../config/theme/app_palette.dart';
import '../../config/theme/app_radius.dart';

/// Segmento de [SegmentedControl].
class SegmentItem<T> {
  final T value;
  final String label;

  const SegmentItem({required this.value, required this.label});
}

/// Selector segmentado con indicador animado (200 ms).
class SegmentedControl<T> extends StatelessWidget {
  static const animationDuration = Duration(milliseconds: 200);

  final List<SegmentItem<T>> segments;
  final T selected;
  final ValueChanged<T>? onChanged;

  const SegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  }) : assert(segments.length >= 2);

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final selectedIndex = segments.indexWhere((s) => s.value == selected);
    final count = segments.length;

    return Container(
      constraints: const BoxConstraints(minHeight: 44),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(AppRadius.field),
      ),
      child: Stack(
        children: [
          if (selectedIndex >= 0)
            Positioned.fill(
              child: AnimatedAlign(
                duration: animationDuration,
                curve: Curves.easeOutCubic,
                alignment: Alignment(
                  count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
                  0,
                ),
                child: FractionallySizedBox(
                  widthFactor: 1 / count,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: p.shadow, blurRadius: 3, offset: const Offset(0, 1)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == selectedIndex,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: onChanged == null ? null : () => onChanged!(segments[i].value),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 36),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            child: Text(
                              segments[i].label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: i == selectedIndex ? FontWeight.w700 : FontWeight.w600,
                                color: i == selectedIndex ? p.ink : p.ink2,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
