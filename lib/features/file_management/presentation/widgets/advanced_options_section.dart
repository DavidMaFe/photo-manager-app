import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/folder_selector.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class AdvancedOptionsSection extends StatelessWidget {

  final ServerAction? selectedAction;
  final ValueChanged<ServerAction?> onActionChanged;
  final String? selectedFolderId;
  final ValueChanged<String?> onFolderSelected;
  final String? newFolderName;
  final ValueChanged<String> onNewFolderNameChanged;
  final bool keepOnDevice;
  final ValueChanged<bool> onKeepOnDeviceChanged;

  const AdvancedOptionsSection({
    super.key,
    required this.selectedAction,
    required this.onActionChanged,
    required this.selectedFolderId,
    required this.onFolderSelected,
    required this.newFolderName,
    required this.onNewFolderNameChanged,
    required this.keepOnDevice,
    required this.onKeepOnDeviceChanged
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.advancedOptionsTitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300)
          ),
          child: Column(
            children: [

              _AdvancedOptionCard(
                  title: l10n.saveInRootTitle,
                  subtitle: l10n.saveInRootSubtitle,
                  isSelected: selectedAction == ServerAction.save,
                  isFirst: true,
                  onTap: () => onActionChanged(ServerAction.save),
              ),

              const Divider(height: 1),

              _AdvancedOptionItemExpandable(
                  title: l10n.moveToFolderTitle,
                  subtitle: l10n.moveToFolderSubtitle,
                  isSelected: selectedAction == ServerAction.folder,
                  onTap: () => onActionChanged(ServerAction.folder),
                  child: selectedAction == ServerAction.folder
                      ? Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
                      child: FolderSelector(
                          selectedFolderId: selectedFolderId,
                          onFolderSelected: onFolderSelected
                      )
                  )
                      : null
              ),

              const Divider(height: 1),

              _AdvancedOptionItemExpandable(
                  title: l10n.newFolderTitle,
                  subtitle: l10n.newFolderSubtitle,
                  isSelected: selectedAction == ServerAction.newFolder,
                  onTap: () => onActionChanged(ServerAction.newFolder),
                  child: selectedAction == ServerAction.newFolder
                      ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.nameFolder,
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.create_new_folder),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      onChanged: onNewFolderNameChanged,
                    ),
                  )
                      : null
              ),

              const Divider(height: 1),

              _AdvancedOptionCard(
                  title: l10n.deleteTitle,
                  subtitle: l10n.deleteSubtitle,
                  isSelected: selectedAction == ServerAction.delete,
                  isLast: true,
                  onTap: () => onActionChanged(ServerAction.delete),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdvancedOptionCard extends StatelessWidget {

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  const _AdvancedOptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.transparent : Colors.grey[50],
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(12) : Radius.zero,
        bottom: isLast ? const Radius.circular(12) : Radius.zero,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(12) : Radius.zero,
          bottom: isLast ? const Radius.circular(12) : Radius.zero,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? PhotoManagerColors.primary : Colors.grey.shade400,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? PhotoManagerColors.primary : Colors.black87
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600]
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class _AdvancedOptionItemExpandable extends StatelessWidget {

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? child;

  const _AdvancedOptionItemExpandable({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.transparent : Colors.grey[50],
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                    color: isSelected ? PhotoManagerColors.primary : Colors.grey.shade400,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: isSelected ? PhotoManagerColors.primary : Colors.black87
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600]
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          if (child != null) child!
        ],
      ),
    );
  }
}