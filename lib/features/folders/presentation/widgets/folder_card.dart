import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';


class FolderCard extends StatelessWidget {

  final Folder folder;
  final VoidCallback? onTap;
  final VoidCallback? onRename;
  final VoidCallback? onDelete;

  const FolderCard({
    super.key,
    required this.folder,
    required this.onTap,
    this.onRename,
    this.onDelete
  });

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.palette.accent.withValues(alpha: 0.1),
              context.palette.accent.withValues(alpha: 0.05)
            ]
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: context.palette.accent.withValues(alpha: 0.2),
            width: 1
          )
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.palette.accent.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Icon(
                      Icons.folder,
                      color: context.palette.accent,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    folder.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.palette.ink
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 14,
                        color: context.palette.ink2
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${folder.fileCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.ink2
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.folder,
                        size: 14,
                        color: context.palette.ink2
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${folder.subfolderCount}',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.palette.ink2
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            if (onRename != null || onDelete != null)
              Positioned(
                top: 4,
                right: 4,
                child: PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.palette.ink2,
                    size: 20
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)
                  ),
                  onSelected: (value) {
                    if (value == 'rename' && onRename != null) {
                      onRename!();
                    } else if (value == 'delete' && onDelete != null) {
                      onDelete!();
                    }
                  },
                  itemBuilder: (context) => [
                    if (onRename != null)
                      PopupMenuItem(
                        value: 'rename',
                        child: Row(
                          children: [
                            const Icon(Icons.edit, size: 20),
                            const SizedBox(width: 12),
                            Text(l10n.rename)
                          ],
                        ),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: context.palette.danger),
                            const SizedBox(width: 12),
                            Text(l10n.delete, style: TextStyle(color: context.palette.dangerInk))
                          ],
                        ),
                      )
                  ],
                ),
              )
          ],
        ),
      ),
    );
  }
}