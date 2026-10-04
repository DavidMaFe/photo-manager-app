import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/constants/app_constants.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/dashed_border.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

import '../../domain/entities/cover_target.dart';
import '../../domain/entities/folder_covers.dart';
import '../bloc/cover_picker/cover_picker_cubit.dart';
import '../bloc/cover_picker/cover_picker_state.dart';
import 'cover_thumbnail.dart';


/// How the "Use as cover" sheet ended.
sealed class CoverPickerResult {
  const CoverPickerResult();
}

/// Covers saved in [changedAlbums] albums; [folders] has their final covers.
class CoversSaved extends CoverPickerResult {
  final List<FolderCovers> folders;
  final int changedAlbums;

  const CoversSaved({required this.folders, required this.changedAlbums});
}

/// The photos share no album, so there is nothing to choose.
class NoSharedAlbum extends CoverPickerResult {
  const NoSharedAlbum();
}


/// "Use as cover" sheet for 1–3 photos: the tree of albums they can be covers
/// of (root first), each with a tick, what will happen and its 3 cover places.
/// A full album asks which cover to replace before saving.
class CoverPickerSheet extends StatelessWidget {

  /// Indent of each tree level.
  static const double levelIndent = 22;

  const CoverPickerSheet({super.key});

  /// Completes with the result, or `null` when cancelled.
  static Future<CoverPickerResult?> show(BuildContext context, List<String> fileIds) {
    return showAppSheet<CoverPickerResult>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<CoverPickerCubit>()..load(fileIds),
        child: const CoverPickerSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoverPickerCubit, CoverPickerState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == CoverPickerStatus.saved) {
          Navigator.pop(context, CoversSaved(folders: state.savedFolders, changedAlbums: state.changeCount));
        } else if (state.status == CoverPickerStatus.noSharedAlbum) {
          Navigator.pop(context, const NoSharedAlbum());
        }
      },
      builder: (context, state) => _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, CoverPickerState state) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<CoverPickerCubit>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _Header(fileIds: state.fileIds),
        const SizedBox(height: 20),
        switch (state.status) {
          CoverPickerStatus.loading || CoverPickerStatus.noSharedAlbum => const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          CoverPickerStatus.failure => _ErrorLine(
              message: FailureMessageHelper.getMessage(context, state.failure!),
              onRetry: () => cubit.load(state.fileIds),
            ),
          _ => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < state.targets.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _TargetRow(target: state.targets[i], state: state),
                ],
              ],
            ),
        },
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Symbols.info_rounded, size: 18, color: p.ink3),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.coverTreeNote,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ),
          ],
        ),
        if (state.failure != null && state.status == CoverPickerStatus.ready) ...[
          const SizedBox(height: 12),
          _ErrorLine(message: FailureMessageHelper.getMessage(context, state.failure!)),
        ],
        const SizedBox(height: 20),
        AppButton.primary(
          label: l10n.saveChangesCount(state.changeCount),
          loading: state.status == CoverPickerStatus.saving,
          onPressed: state.canSave ? cubit.save : null,
        ),
        const SizedBox(height: 4),
        AppButton.text(label: l10n.cancel, onPressed: () => Navigator.pop(context)),
      ],
    );
  }
}


/// Photo (or stack of photos), title and explanation.
class _Header extends StatelessWidget {
  final List<String> fileIds;

  const _Header({required this.fileIds});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final preview = fileIds.take(kMaxAlbumCovers).toList();

    return Row(
      children: [
        if (preview.length <= 1)
          CoverThumbnail(fileId: preview.isEmpty ? '' : preview.first, size: 48, radius: 12)
        else
          SizedBox(
            width: 40.0 + (preview.length - 1) * 26,
            height: 40,
            child: Stack(
              children: [
                for (var i = 0; i < preview.length; i++)
                  Positioned(
                    left: i * 26.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: p.surface, width: 2),
                      ),
                      child: CoverThumbnail(fileId: preview[i], size: 36, radius: 10),
                    ),
                  ),
              ],
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.useAsCover, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
              const SizedBox(height: 2),
              Text(
                l10n.useAsCoverBody,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}


/// One album of the tree, indented by depth with an "L" connector.
class _TargetRow extends StatelessWidget {
  final CoverTarget target;
  final CoverPickerState state;

  const _TargetRow({required this.target, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<CoverPickerCubit>();
    final status = state.rowStatus(target);
    final changed = state.hasChange(target);
    final checked = state.isChecked(target);
    final (statusText, statusColor) = _statusOf(status, l10n, p);
    final radius = BorderRadius.circular(18);
    final indent = target.depth * CoverPickerSheet.levelIndent;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: changed ? p.accentSoft.withValues(alpha: 0.5) : p.surface,
        borderRadius: radius,
        border: Border.all(color: changed ? p.accent : p.line, width: changed ? 2 : 1.5),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              checked: checked,
              label: '${target.name}, $statusText',
              excludeSemantics: true,
              onTap: () => cubit.toggle(target.folderId),
              child: InkWell(
                borderRadius: radius,
                onTap: () => cubit.toggle(target.folderId),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Icon(
                          checked ? Symbols.check_box_rounded : Symbols.check_box_outline_blank_rounded,
                          size: 26,
                          fill: checked ? 1 : 0,
                          color: p.accent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Text(
                                    target.name,
                                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink),
                                  ),
                                  if (target.containsDirectly)
                                    _HereTag(label: state.fileIds.length > 1 ? l10n.photosAreHere : l10n.photoIsHere),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                statusText,
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: statusColor),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _Slots(covers: state.previewCovers(target), photoIds: state.fileIds),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (state.replacementsNeeded(target) > 0)
              _ReplacementPicker(target: target, state: state),
          ],
        ),
      ),
    );

    if (target.depth == 0) return card;
    return CustomPaint(
      painter: _TreeConnectorPainter(color: p.line, x: indent - CoverPickerSheet.levelIndent / 2),
      child: Padding(padding: EdgeInsets.only(left: indent), child: card),
    );
  }

  (String, Color) _statusOf(CoverRowStatus status, AppLocalizations l10n, AppPalette p) {
    return switch (status) {
      CoverRowStatus.alreadyCover => (l10n.coverAlreadyHint, p.ink2),
      CoverRowStatus.willAdd => (l10n.coverWillAdd(state.coverCountAfterAdding(target)), p.accentInk),
      CoverRowStatus.needsReplacement => switch (state.replacementsNeeded(target)) {
          1 => (l10n.coverFullChoose, p.reviewInk),
          final needed => (l10n.coverFullChooseMany(needed), p.reviewInk),
        },
      CoverRowStatus.willRemove => (l10n.coverWillRemove, p.dangerInk),
      CoverRowStatus.unchanged => (l10n.coverCount(target.covers.length), p.ink2),
    };
  }
}


/// "The photo is here" tag next to the album where the photo is.
class _HereTag extends StatelessWidget {
  final String label;

  const _HereTag({required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: p.surface2, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: p.ink2)),
    );
  }
}


/// The 3 cover places of an album: its covers (the photos with a double ring)
/// and dashed empty places.
class _Slots extends StatelessWidget {
  static const double size = 26;

  final List<String> covers;
  final List<String> photoIds;

  const _Slots({required this.covers, required this.photoIds});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < kMaxAlbumCovers; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            if (i < covers.length)
              photoIds.contains(covers[i])
                  ? _DoubleRing(radius: 6, child: CoverThumbnail(fileId: covers[i], size: size - 8, radius: 3))
                  : CoverThumbnail(fileId: covers[i], size: size, radius: 6)
            else
              SizedBox.square(
                dimension: size,
                child: DashedBorder(radius: 6, color: p.ink3.withValues(alpha: 0.6), strokeWidth: 1.5, child: const SizedBox.expand()),
              ),
          ],
        ],
      ),
    );
  }
}


/// White ring (2) inside an accent ring (2) around the photo being used.
class _DoubleRing extends StatelessWidget {
  final double radius;
  final Widget child;

  const _DoubleRing({required this.radius, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.accent, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius - 2),
          border: Border.all(color: p.surface, width: 2),
        ),
        child: child,
      ),
    );
  }
}


/// Covers of a full album to choose which one the photo replaces (a radio
/// group; several choices when various photos do not fit).
class _ReplacementPicker extends StatelessWidget {
  final CoverTarget target;
  final CoverPickerState state;

  const _ReplacementPicker({required this.target, required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final cubit = context.read<CoverPickerCubit>();
    final replaceable = state.replaceableCovers(target);
    final chosen = state.replacementsOf(target);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Row(
        children: [
          for (var i = 0; i < kMaxAlbumCovers; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(
              child: i >= replaceable.length
                  ? const SizedBox()
                  : AspectRatio(
                      aspectRatio: 1,
                      child: _ReplaceOption(
                        fileId: replaceable[i],
                        selected: chosen.contains(replaceable[i]),
                        semanticLabel: l10n.replaceCoverOf(
                          target.covers.indexWhere((c) => c.fileId == replaceable[i]) + 1,
                          target.name,
                        ),
                        replaceLabel: l10n.replace,
                        palette: p,
                        onTap: () => cubit.chooseReplacement(target.folderId, replaceable[i]),
                      ),
                    ),
            ),
          ],
        ],
      ),
    );
  }
}


class _ReplaceOption extends StatelessWidget {
  final String fileId;
  final bool selected;
  final String semanticLabel;
  final String replaceLabel;
  final AppPalette palette;
  final VoidCallback onTap;

  const _ReplaceOption({
    required this.fileId,
    required this.selected,
    required this.semanticLabel,
    required this.replaceLabel,
    required this.palette,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final photo = LayoutBuilder(
      builder: (context, constraints) => CoverThumbnail(
        fileId: fileId,
        size: constraints.maxWidth,
        radius: selected ? 8 : 12,
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: selected
            ? _DoubleRing(
                radius: 12,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    photo,
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: p.media.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.swap_horiz_rounded, size: 22, color: p.onMedia),
                          Text(
                            replaceLabel,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: p.onMedia),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : photo,
      ),
    );
  }
}


/// "L" line from the parent level to a nested album card.
class _TreeConnectorPainter extends CustomPainter {
  final Color color;

  /// Horizontal position of the vertical line.
  final double x;

  const _TreeConnectorPainter({required this.color, required this.x});

  @override
  void paint(Canvas canvas, Size size) {
    const corner = 8.0;
    // To the middle of the first line of the card (its tick).
    const y = 28.0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..moveTo(x, -8)
      ..lineTo(x, y - corner)
      ..quadraticBezierTo(x, y, x + corner, y)
      ..lineTo(x + CoverPickerSheet.levelIndent / 2, y);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_TreeConnectorPainter oldDelegate) => oldDelegate.color != color || oldDelegate.x != x;
}


class _ErrorLine extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _ErrorLine({required this.message, this.onRetry});

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
