import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/navigation/route_names.dart';
import 'package:photo_manager_app/core/widgets/list_row.dart';
import 'package:photo_manager_app/features/local_albums/domain/entities/local_album.dart';
import 'package:photo_manager_app/features/local_albums/domain/enums/local_album_mode.dart';
import 'package:photo_manager_app/features/local_albums/domain/use_cases/get_local_albums_use_case.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// «Qué copiar» of the backup settings: «Álbumes del móvil», with how many there are and how many are not backed up.
class LocalAlbumsSettingsTile extends StatefulWidget {
  final Future<List<LocalAlbum>> Function()? loadAlbums;

  const LocalAlbumsSettingsTile({super.key, this.loadAlbums});

  @override
  State<LocalAlbumsSettingsTile> createState() => _LocalAlbumsSettingsTileState();
}

class _LocalAlbumsSettingsTileState extends State<LocalAlbumsSettingsTile> {
  List<LocalAlbum>? _albums;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final albums = await (widget.loadAlbums ?? sl<GetLocalAlbumsUseCase>().call)();
      if (mounted) setState(() => _albums = albums);
    } catch (_) {
      // Without a summary: the page says what happened
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final inGallery = _albums?.where((album) => album.assetCount != null).toList();
    final excluded = inGallery?.where((album) => album.mode == LocalAlbumMode.excluded).length ?? 0;
    final summary = inGallery == null || inGallery.isEmpty
        ? null
        : excluded == 0
            ? l10n.localAlbumsSummaryAll(inGallery.length)
            : l10n.localAlbumsSummary(inGallery.length, excluded);

    return ListRowGroup(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        ListRow(
          key: const ValueKey('local-albums-settings'),
          icon: Symbols.photo_album_rounded,
          title: l10n.localAlbumsTitle,
          subtitle: summary,
          onTap: () async {
            await context.pushNamed(RouteNames.localAlbums);
            _load();
          },
        ),
      ],
    );
  }
}
