import 'package:photo_manager_app/features/gallery/presentation/widgets/file_filter_label.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filter.icon != null) ...[
            Icon(
              filter.icon,
              size: 18,
              color: isSelected ? context.palette.onAccent : context.palette.accent,
            ),
            const SizedBox(width: 6)
          ],
          Text(filter.label(l10n)),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onFilterSelected(filter),
      backgroundColor: context.palette.surface,
      selectedColor: context.palette.accent,
      checkmarkColor: context.palette.onAccent,
      labelStyle: TextStyle(
        color: isSelected ? context.palette.onAccent : context.palette.accentInk,
        fontWeight: FontWeight.w600,
        fontSize: 14
      ),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
              color: isSelected ? context.palette.accent : context.palette.line,
              width: 1.5
          )
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}