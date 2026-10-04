import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_bloc.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_event.dart';
import 'package:photo_manager_app/features/favorites/presentation/bloc/favorites_state.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// "Favorite" action of the viewer bar. Toggles at once (the [FavoritesBloc]
/// goes back and shows a snackbar if the server fails) and pops the heart
/// when it turns on.
class FavoriteViewerButton extends StatefulWidget {
  final GalleryFile file;

  const FavoriteViewerButton({super.key, required this.file});

  @override
  State<FavoriteViewerButton> createState() => _FavoriteViewerButtonState();
}

class _FavoriteViewerButtonState extends State<FavoriteViewerButton> with SingleTickerProviderStateMixin {

  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  // 1 → 1.25 → 1
  late final Animation<double> _scale = TweenSequence([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25), weight: 1),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0), weight: 1),
  ]).animate(CurvedAnimation(parent: _pop, curve: Curves.easeOut));

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _toggle(bool isFavorite) {
    context.read<FavoritesBloc>().add(SetFavorites(files: [widget.file], favorite: !isFavorite));
    if (!isFavorite) _pop.forward(from: 0);
  }

  void _showFailure(BuildContext context, FavoritesState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.favoriteError)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return BlocConsumer<FavoritesBloc, FavoritesState>(
      listenWhen: (previous, current) => current.outcome is FavoritesFailed && previous.outcome != current.outcome,
      listener: _showFailure,
      builder: (context, state) {
        final isFavorite = state.isFavorite(widget.file.id, fallback: widget.file.isFavorite);
        return Semantics(
          button: true,
          toggled: isFavorite,
          label: l10n.favorite,
          excludeSemantics: true,
          onTap: () => _toggle(isFavorite),
          child: AnimatedBuilder(
            animation: _scale,
            builder: (context, _) => MediaViewerAction(
              icon: Symbols.favorite_rounded,
              label: l10n.favorite,
              iconFill: isFavorite ? 1 : 0,
              iconColor: isFavorite ? p.favorite : null,
              color: isFavorite ? p.favoriteInk : null,
              labelWeight: isFavorite ? FontWeight.w800 : FontWeight.w700,
              iconScale: _scale.value,
              onPressed: () => _toggle(isFavorite),
            ),
          ),
        );
      },
    );
  }
}
