import 'package:flutter/material.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/folder.dart';


/// Parent path of the current album ("Albums › Trips"). Tapping it goes to the
/// parent album (or the album list for root albums).
class BreadcrumbsBar extends StatelessWidget {

  final Folder currentFolder;

  /// Called with the parent folder id, or `null` for the album list.
  final ValueChanged<String?>? onNavigate;

  const BreadcrumbsBar({super.key, required this.currentFolder, this.onNavigate});

  /// "Albums › Trips" for the album at "/Trips/Japan". The server path is
  /// built from the album names and always ends with the current album.
  static String trailFor(Folder folder, String rootLabel) {
    final parts = folder.path.split('/').where((p) => p.isNotEmpty).toList();
    if (parts.isNotEmpty) parts.removeLast();
    return [rootLabel, ...parts].join(' › ');
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return InkWell(
      onTap: onNavigate == null ? null : () => onNavigate!(currentFolder.parentFolderId),
      borderRadius: BorderRadius.circular(8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 32),
        child: Align(
          alignment: Alignment.centerLeft,
          widthFactor: 1,
          child: Text(
            trailFor(currentFolder, l10n.folders),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: context.palette.ink2),
          ),
        ),
      ),
    );
  }
}
