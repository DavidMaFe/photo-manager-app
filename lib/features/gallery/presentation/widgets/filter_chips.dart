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
      child: SingleChildScrollView(
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
    );
  }

  Widget _buildFilterChip(BuildContext context, FileFilter filter) {

    final isSelected = selectedFilter == filter;

    return FilterChip(
      label: Text(filter.displayName),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
      checkmarkColor: PhotoManagerColors.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : PhotoManagerColors.primary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
      ),
    );
  }
}