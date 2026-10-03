import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
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
              Icon(
                Icons.folder,
                size: 20,
                color: context.palette.accent
              ),
              const SizedBox(width: 4),
              Text(
                l10n.folders,
                style: TextStyle(
                  fontSize: 14,
                  color: context.palette.accentInk,
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
              color: context.palette.ink2
            ),
          ),
          Expanded(
            child: Text(
              currentFolder.name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: context.palette.ink
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
