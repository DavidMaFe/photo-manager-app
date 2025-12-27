import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class GalleryHeader extends StatelessWidget implements PreferredSizeWidget {

  const GalleryHeader({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return AppBar(
      title: Text(l10n.gallery),
      centerTitle: false,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}