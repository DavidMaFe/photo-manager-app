import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/service/error_notification_service.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/core/widgets/secondary_top_bar.dart';
import 'package:photo_manager_app/features/local_albums/presentation/bloc/local_albums_cubit.dart';
import 'package:photo_manager_app/features/local_albums/presentation/widgets/local_album_row.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// The albums of the gallery and what the backups do with each one (ROADMAP-local-albums.md):
/// - [review]: «Tus álbumes», once after the onboarding (or after the update), saved with «Continuar»;
/// - otherwise «Álbumes del móvil», from the backup settings, where each change is saved at once.
class LocalAlbumsPage extends StatelessWidget {
  final bool review;

  const LocalAlbumsPage({super.key, this.review = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return BlocConsumer<LocalAlbumsCubit, LocalAlbumsState>(
      listenWhen: (previous, current) =>
          current.failure != null || (current.status == LocalAlbumsStatus.done && previous.status != current.status),
      listener: (context, state) {
        if (state.status == LocalAlbumsStatus.done) {
          context.pop();
          return;
        }
        final failure = state.failure;
        if (failure != null && state.status != LocalAlbumsStatus.error) {
          ErrorNotificationService.showError(context, failure, config: ErrorDisplayConfig.snackBar);
          context.read<LocalAlbumsCubit>().failureShown();
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: p.background,
          appBar: SecondaryTopBar(title: review ? l10n.localAlbumsReviewTitle : l10n.localAlbumsTitle),
          body: SafeArea(child: _body(context, state, l10n)),
          bottomNavigationBar: review && state.status == LocalAlbumsStatus.loaded
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    child: AppButton(
                      key: const ValueKey('local-albums-continue'),
                      label: l10n.continueLabel,
                      loading: state.saving,
                      onPressed: state.saving ? null : () => context.read<LocalAlbumsCubit>().finish(),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _body(BuildContext context, LocalAlbumsState state, AppLocalizations l10n) {
    final cubit = context.read<LocalAlbumsCubit>();
    switch (state.status) {
      case LocalAlbumsStatus.loading:
      case LocalAlbumsStatus.done:
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      case LocalAlbumsStatus.noPermission:
        return EmptyState(
          icon: Symbols.no_photography_rounded,
          title: l10n.localAlbumsNoPermission,
          message: l10n.localAlbumsNoPermissionMessage,
          actionLabel: l10n.localAlbumsGrantPermission,
          onAction: cubit.requestPermission,
        );
      case LocalAlbumsStatus.error:
        return EmptyState(
          icon: Symbols.error_rounded,
          title: l10n.localAlbumsLoadError,
          actionLabel: l10n.retry,
          onAction: cubit.load,
        );
      case LocalAlbumsStatus.loaded:
        if (state.albums.isEmpty) {
          return EmptyState(
            icon: Symbols.photo_library_rounded,
            title: l10n.localAlbumsEmpty,
            message: l10n.localAlbumsEmptyMessage,
          );
        }
        return _AlbumList(state: state, review: review);
    }
  }
}

class _AlbumList extends StatelessWidget {
  final LocalAlbumsState state;
  final bool review;

  const _AlbumList({required this.state, required this.review});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<LocalAlbumsCubit>();
    final textStyle = TextStyle(fontSize: 14, color: p.ink2, height: 1.4);

    return ListView(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(review ? l10n.localAlbumsReviewMessage(state.albums.length) : l10n.localAlbumsMessage,
                  style: textStyle),
              if (review) ...[const SizedBox(height: 8), Text(l10n.localAlbumsReviewHint, style: textStyle)],
              if (state.limitedAccess) ...[
                const SizedBox(height: 8),
                Text(l10n.localAlbumsLimitedAccess,
                    key: const ValueKey('local-albums-limited'), style: textStyle.copyWith(color: p.reviewInk)),
              ],
            ],
          ),
        ),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              for (final album in state.albums)
                LocalAlbumRow(
                  album: album,
                  mode: state.modeOf(album),
                  enabled: !state.saving,
                  onChanged: (mode) =>
                      review ? cubit.choose(album.localAlbumId, mode) : cubit.change(album.localAlbumId, mode),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
