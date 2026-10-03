import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class QuickActionsSection extends StatelessWidget {

  final Function(ManageAction) onActionSelected;

  const QuickActionsSection({super.key, required this.onActionSelected});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.quickActionsTitle,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: context.palette.ink2,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.save,
                iconColor: context.palette.safe,
                backgroundColor: context.palette.safe.withValues(alpha: 0.1),
                title: l10n.saveAndKeepTitle,
                subtitle: l10n.saveAndKeepSubtitle,
                onTap: () {
                  onActionSelected(
                    const ManageAction(serverAction: ServerAction.save, keepOnDevice: true)
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _QuickActionCard(
                icon: Icons.cloud_upload,
                iconColor: context.palette.accent,
                backgroundColor: context.palette.accent.withValues(alpha: 0.1),
                title: l10n.saveAndDeleteTitle,
                subtitle: l10n.saveAndDeleteSubtitle,
                onTap: () {
                  onActionSelected(
                      const ManageAction(serverAction: ServerAction.save, keepOnDevice: false)
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.folder,
                iconColor: context.palette.review,
                backgroundColor: context.palette.review.withValues(alpha: 0.1),
                title: l10n.saveInFolderTitle,
                subtitle: l10n.saveInFolderSubtitle,
                onTap: () {
                  onActionSelected(
                      const ManageAction(serverAction: ServerAction.folder, keepOnDevice: true)
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: _QuickActionCard(
                icon: Icons.delete,
                iconColor: context.palette.danger,
                backgroundColor: context.palette.danger.withValues(alpha: 0.1),
                title: l10n.deleteBothTitle,
                subtitle: l10n.deleteBothSubtitle,
                onTap: () {
                  onActionSelected(
                      const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false)
                  );
                },
              ),
            ),
          ],
        )
      ],
    );
  }
}


class _QuickActionCard extends StatelessWidget {

  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.subtitle,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Material(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 120),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                    icon,
                    color: iconColor,
                    size: 32
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: iconColor.withValues(alpha: 0.7),
                      fontSize: 12
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              ],
            ),
          ),
        ),
      )
    );
  }
}

