import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// An album of the gallery: its name, its number of files and its option.
class LocalAlbumRow extends StatelessWidget {
  final LocalAlbum album;
  final LocalAlbumMode mode;
  final bool enabled;
  final ValueChanged<LocalAlbumMode> onChanged;

  const LocalAlbumRow({
    super.key,
    required this.album,
    required this.mode,
    required this.onChanged,
    this.enabled = true,
  });

  static String labelOf(LocalAlbumMode mode, AppLocalizations l10n) => switch (mode) {
        LocalAlbumMode.album => l10n.localAlbumModeAlbum,
        LocalAlbumMode.backupOnly => l10n.localAlbumModeBackupOnly,
        LocalAlbumMode.excluded => l10n.localAlbumModeExcluded,
      };

  static IconData iconOf(LocalAlbumMode mode) => switch (mode) {
        LocalAlbumMode.album => Symbols.photo_album_rounded,
        LocalAlbumMode.backupOnly => Symbols.cloud_upload_rounded,
        LocalAlbumMode.excluded => Symbols.cloud_off_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final count = album.assetCount;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(iconOf(mode), color: mode == LocalAlbumMode.excluded ? p.ink3 : p.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(album.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: p.ink)),
                if (count != null)
                  Text(l10n.localAlbumFiles(count), style: TextStyle(fontSize: 13, color: p.ink2)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          DropdownButton<LocalAlbumMode>(
            key: ValueKey('local-album-mode-${album.localAlbumId}'),
            value: mode,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            onChanged: enabled ? (value) => value == null ? null : onChanged(value) : null,
            items: [
              for (final option in LocalAlbumMode.values)
                DropdownMenuItem(value: option, child: Text(labelOf(option, l10n))),
            ],
          ),
        ],
      ),
    );
  }
}
