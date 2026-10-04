import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/album_cover.dart';
import '../../domain/entities/folder.dart';
import '../bloc/album_covers/album_covers_cubit.dart';
import '../bloc/album_covers/album_covers_state.dart';
import 'album_mosaic.dart';
import 'cover_thumbnail.dart';


/// "Cover of {album}" sheet: preview of the mosaic and the chosen covers,
/// which can be removed (with undo) and reordered. "Done" saves the changes.
class AlbumCoversSheet extends StatelessWidget {
  final Folder folder;

  const AlbumCoversSheet({super.key, required this.folder});

  /// Completes with `true` when the covers changed.
  static Future<bool?> show(BuildContext context, Folder folder) {
    return showAppSheet<bool>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<AlbumCoversCubit>()..load(folder.id),
        child: AlbumCoversSheet(folder: folder),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AlbumCoversCubit, AlbumCoversState>(
      listenWhen: (previous, current) => current.status == AlbumCoversStatus.saved && previous.status != current.status,
      listener: (context, state) => Navigator.pop(context, state.changesSaved),
      builder: (context, state) => _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, AlbumCoversState state) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<AlbumCoversCubit>();
    final covers = state.covers;
    final isAutomatic = covers.isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.albumCoverTitle(folder.name),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink),
        ),
        const SizedBox(height: 2),
        Text(
          isAutomatic ? l10n.albumCoverAuto : l10n.albumCoverSubtitle(covers.length),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
        ),
        const SizedBox(height: 16),
        _Preview(
          fileIds: isAutomatic ? folder.fallbackCoverFileIds : [for (final c in covers) c.fileId],
          automatic: isAutomatic,
        ),
        const SizedBox(height: 16),
        if (state.status == AlbumCoversStatus.loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          )
        else if (state.status == AlbumCoversStatus.failure)
          _InlineError(
            message: FailureMessageHelper.getMessage(context, state.failure!),
            onRetry: () => cubit.load(folder.id),
          )
        else if (covers.isNotEmpty)
          _CoverList(covers: covers),
        if (state.lastRemoved != null) ...[
          const SizedBox(height: 8),
          _UndoRow(onUndo: cubit.undoRemove),
        ],
        if (state.failure != null && state.status != AlbumCoversStatus.failure) ...[
          const SizedBox(height: 8),
          _InlineError(message: FailureMessageHelper.getMessage(context, state.failure!)),
        ],
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Symbols.info_rounded, size: 18, color: p.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.addCoverHint,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        AppButton.primary(
          label: l10n.done,
          loading: state.status == AlbumCoversStatus.saving,
          onPressed: state.status == AlbumCoversStatus.failure
              ? () => Navigator.pop(context, false)
              : cubit.save,
        ),
      ],
    );
  }
}


/// Mosaic as it will look in Albums (dimmed while the covers are automatic).
class _Preview extends StatelessWidget {
  final List<String> fileIds;
  final bool automatic;

  const _Preview({required this.fileIds, required this.automatic});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Row(
      children: [
        Opacity(
          opacity: automatic ? 0.5 : 1,
          child: SizedBox.square(dimension: 132, child: AlbumMosaic(fileIds: fileIds, radius: 22)),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                automatic ? l10n.coverAutomatic : l10n.previewInAlbums,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.previewInAlbumsBody,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/// Covers in order; drag the handle (or use the "Move up"/"Move down" actions) to reorder.
class _CoverList extends StatelessWidget {
  final List<AlbumCover> covers;

  const _CoverList({required this.covers});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final cubit = context.read<AlbumCoversCubit>();

    return DecoratedBox(
      decoration: BoxDecoration(color: p.background, borderRadius: BorderRadius.circular(20)),
      child: ReorderableListView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        buildDefaultDragHandles: false,
        padding: const EdgeInsets.symmetric(vertical: 4),
        onReorder: cubit.reorder,
        children: [
          for (var i = 0; i < covers.length; i++)
            _CoverRow(key: ValueKey(covers[i].fileId), cover: covers[i], index: i, count: covers.length),
        ],
      ),
    );
  }
}


class _CoverRow extends StatelessWidget {
  final AlbumCover cover;
  final int index;
  final int count;

  const _CoverRow({super.key, required this.cover, required this.index, required this.count});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<AlbumCoversCubit>();
    final position = [l10n.coverMain, l10n.coverSecond, l10n.coverThird][index.clamp(0, 2)];
    final origin = cover.isFromThisAlbum ? l10n.fromThisAlbum : l10n.fromAlbum(cover.sourceFolderPath.join(' › '));

    return Semantics(
      customSemanticsActions: {
        if (index > 0) CustomSemanticsAction(label: l10n.moveUp): () => cubit.reorder(index, index - 1),
        if (index < count - 1) CustomSemanticsAction(label: l10n.moveDown): () => cubit.reorder(index, index + 2),
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            ReorderableDragStartListener(
              index: index,
              child: SizedBox.square(
                dimension: 44,
                child: Icon(Symbols.drag_indicator_rounded, size: 22, color: p.ink3),
              ),
            ),
            CoverThumbnail(fileId: cover.fileId, size: 52, radius: 10),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(position, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink)),
                  const SizedBox(height: 2),
                  Text(
                    origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: l10n.removeCover,
              onPressed: () => cubit.remove(cover.fileId),
              style: IconButton.styleFrom(
                backgroundColor: p.dangerSoft,
                fixedSize: const Size.square(40),
                minimumSize: const Size.square(44),
              ),
              icon: Icon(Symbols.close_rounded, size: 20, color: p.dangerInk),
            ),
          ],
        ),
      ),
    );
  }
}


/// "Removed from the cover · Undo" (a snackbar would hide behind the sheet).
class _UndoRow extends StatelessWidget {
  final VoidCallback onUndo;

  const _UndoRow({required this.onUndo});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(14)),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.coverRemoved,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink),
              ),
            ),
            TextButton(
              onPressed: onUndo,
              style: TextButton.styleFrom(foregroundColor: p.accentInk, minimumSize: const Size(44, 44)),
              child: Text(l10n.undo, style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}


class _InlineError extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _InlineError({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return Semantics(
      liveRegion: true,
      child: Row(
        children: [
          Icon(Symbols.error_rounded, size: 20, color: p.dangerInk),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.dangerInk)),
          ),
          if (onRetry != null)
            AppButton.secondary(
              label: l10n.retry,
              icon: Symbols.refresh_rounded,
              size: AppButtonSize.small,
              onPressed: onRetry,
            ),
        ],
      ),
    );
  }
}
