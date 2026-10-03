import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';

class DateSectionHeader extends StatelessWidget {
  final String label;

  const DateSectionHeader({
    super.key,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: context.palette.ink,
        ),
      ),
    );
  }
}

/// Delegate for creating sticky headers in SliverPersistentHeader
class DateSectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final double height;

  DateSectionHeaderDelegate({
    required this.label,
    this.height = 48,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DateSectionHeader(label: label);
  }

  @override
  bool shouldRebuild(DateSectionHeaderDelegate oldDelegate) {
    return oldDelegate.label != label;
  }
}
