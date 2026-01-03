import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/features/gallery/domain/enums/file_filter.dart';


class FilterChips extends StatelessWidget {

  final FileFilter selectedFilter;
  final ValueChanged<FileFilter> onFilterSelected;

  const FilterChips({super.key, required this.selectedFilter, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: FileFilter.values.map((filter) {
                return Padding(
                  padding: const EdgeInsetsGeometry.only(right: 8),
                  child: _buildFilterChip(context, filter),
                );
              }).toList(),
            ),
          ),
        ],
      )
    );
  }

  Widget _buildFilterChip(BuildContext context, FileFilter filter) {

    final isSelected = selectedFilter == filter;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filter.icon != null) ...[
            Icon(
              filter.icon,
              size: 18,
              color: isSelected ? Colors.white : PhotoManagerColors.primary,
            ),
            const SizedBox(width: 6)
          ],
          Text(filter.displayName),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      backgroundColor: Colors.white,
      selectedColor: PhotoManagerColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : PhotoManagerColors.primary,
        fontWeight: FontWeight.w600,
        fontSize: 14
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? PhotoManagerColors.primary : Colors.grey.shade300,
              width: 1.5
          )
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}