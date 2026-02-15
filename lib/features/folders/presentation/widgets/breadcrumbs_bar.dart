import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';


class BreadcrumbsBar extends StatelessWidget {

  final Folder currentFolder;
  final ValueChanged<String?>? onNavigate;

  const BreadcrumbsBar({super.key, required this.currentFolder, this.onNavigate});

  @override
  Widget build(BuildContext context) {

    final pathParts = currentFolder.path.split('/').where((p) =>p.isNotEmpty).toList();
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        GestureDetector(
          onTap: () => onNavigate?.call(null),
          child: Row(
            children: [
              const Icon(
                Icons.folder,
                size: 20,
                color: PhotoManagerColors.primary
              ),
              const SizedBox(width: 4),
              Text(
                l10n.folders,
                style: const TextStyle(
                  fontSize: 14,
                  color: PhotoManagerColors.primary,
                  fontWeight: FontWeight.w500
                ),
              )
            ],
          ),
        ),
        if (pathParts.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: Colors.grey.shade600
            ),
          ),
          Expanded(
            child: Text(
              currentFolder.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          )
        ]
      ],
    );
  }
}
