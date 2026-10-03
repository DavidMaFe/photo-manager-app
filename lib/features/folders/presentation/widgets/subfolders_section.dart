import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/folders/domain/entities/folder.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class SubfoldersSection extends StatelessWidget {

  final List<Folder> subfolders;
  final ValueChanged<Folder> onFolderTap;

  const SubfoldersSection({super.key, required this.subfolders, required this.onFolderTap});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Row(
            children: [
              Icon(
                Icons.folder,
                size: 20,
                color: context.palette.ink2,
              ),
              const SizedBox(width: 8),
              Text(
                l10n.subfolders,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: context.palette.ink
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: context.palette.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Text(
                  '${subfolders.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: context.palette.accentInk
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: subfolders.length,
            itemBuilder: (context, index) {
              final folder = subfolders[index];
              return _SubfolderCard(folder: folder, onTap: () => onFolderTap(folder));
            },
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          height: 1,
          thickness: 1,
          color: context.palette.line,
        ),
        const SizedBox(height: 8)
      ],
    );
  }
}

class _SubfolderCard extends StatelessWidget {

  final Folder folder;
  final VoidCallback onTap;

  const _SubfolderCard({required this.folder, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.palette.accent.withValues(alpha: 0.1),
              context.palette.accent.withValues(alpha: 0.05)
            ]
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.palette.accent.withValues(alpha: 0.2),
            width: 1
          )
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.palette.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8)
              ),
              child: Icon(
                Icons.folder,
                color: context.palette.accent,
                size: 24,
              ),
            ),
            const Spacer(),
            Text(
              folder.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.palette.ink
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 12,
                  color: context.palette.ink2
                ),
                const SizedBox(width: 4),
                Text(
                  '${folder.fileCount}',
                  style: TextStyle(
                    fontSize: 11,
                    color: context.palette.ink2
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}