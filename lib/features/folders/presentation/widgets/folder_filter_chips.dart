import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FolderFilterChips extends StatelessWidget {

  final String? selectedFileType;
  final String? selectedStatus;
  final Function(String?, String?) onFilterSelected;

  const FolderFilterChips({
    super.key,
    this.selectedFileType,
    this.selectedStatus,
    required this.onFilterSelected
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildChip(
                  context,
                  label: l10n.all,
                  isSelected: selectedFileType == null && selectedStatus == null,
                  onTap: () => onFilterSelected(null, null)
                ),
                const SizedBox(width: 8),
                _buildChip(
                    context,
                    label: l10n.photos,
                    icon: Icons.photo,
                    isSelected: selectedFileType == 'IMAGE',
                    onTap: () => onFilterSelected('IMAGE', selectedStatus)
                ),
                const SizedBox(width: 8),
                _buildChip(
                    context,
                    label: l10n.videos,
                    icon: Icons.videocam,
                    isSelected: selectedFileType == 'VIDEO',
                    onTap: () => onFilterSelected('VIDEO', selectedStatus)
                ),
                const SizedBox(width: 8),
                _buildChip(
                    context,
                    label: l10n.pendingPlural,
                    icon: Icons.schedule,
                    isSelected: selectedStatus == 'PENDING',
                    onTap: () => onFilterSelected(selectedFileType, 'PENDING')
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildChip(
      BuildContext context, {
        required String label,
        IconData? icon,
        required bool isSelected,
        required VoidCallback onTap
  }) {

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: isSelected ? context.palette.onAccent : context.palette.accent
            ),
            const SizedBox(width: 6)
          ],
          Text(label)
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: context.palette.surface,
      selectedColor: context.palette.accent,
      checkmarkColor: context.palette.surface,
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