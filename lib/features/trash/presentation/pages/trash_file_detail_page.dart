import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_top_bar.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/permanent_delete_confirmation_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/restore_confirmation_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/trash_file_card.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// Trash viewer: same layout as the gallery viewer with restore and
/// delete-forever actions and the deletion countdown.
class TrashFileDetailPage extends StatefulWidget {

  final List<TrashFile> files;
  final int initialIndex;

  const TrashFileDetailPage({
    super.key,
    required this.files,
    required this.initialIndex
  });

  @override
  State<TrashFileDetailPage> createState() => _TrashFileDetailPageState();
}


class _TrashFileDetailPageState extends State<TrashFileDetailPage> {

  /// Space reserved under a video so its own controls stay above the chrome.
  static const double _bottomChromeHeight =
      MediaViewerActionBar.height + MediaViewerThumbnailStrip.height + 12 + 16;

  late PageController _pageController;
  late int _currentIndex;
  bool _chromeVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  TrashFile get _currentFile => widget.files[_currentIndex];

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final file = _currentFile;
    final countdown = l10n.deletesIn(l10n.daysLeft(file.daysUntilPermanentDeletion));

    return Scaffold(
      backgroundColor: palette.media,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.files.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _chromeVisible = true;
              });
            },
            itemBuilder: (context, index) => _buildMediaViewer(widget.files[index], l10n),
          ),

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _chrome(
              MediaViewerTopBar(
                title: DateFormatter.formatDayAndTime(file.capturedAt, context),
                subtitle: _subtitleFor(file, l10n),
                onBack: () => Navigator.pop(context),
                actions: [
                  _CountdownPill(label: countdown, soon: TrashFileCard.isDeletedSoon(file)),
                  MediaViewerIconButton(
                    icon: Symbols.info_rounded,
                    tooltip: l10n.viewerInfo,
                    onPressed: () => FilePropertiesSheet.show(
                      context,
                      file,
                      status: StatusChip(
                        compact: true,
                        icon: Symbols.auto_delete_rounded,
                        label: countdown,
                        variant: TrashFileCard.isDeletedSoon(file)
                            ? StatusChipVariant.danger
                            : StatusChipVariant.neutral,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _chrome(
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.files.length > 1) ...[
                        MediaViewerThumbnailStrip(
                          itemCount: widget.files.length,
                          currentIndex: _currentIndex,
                          thumbnailBuilder: (context, index) => AuthenticatedImage(
                            imageUrl: '${DataConstants.backendBaseUrl}/api/file/${widget.files[index].id}/thumbnail/',
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const SizedBox.shrink(),
                          ),
                          onSelected: (index) => _pageController.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeOut,
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: MediaViewerActionBar(
                          children: [
                            Expanded(
                              child: MediaViewerAction(
                                icon: Symbols.restore_rounded,
                                label: l10n.restore,
                                highlighted: true,
                                onPressed: () => _confirmRestore(context),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: MediaViewerAction(
                                icon: Symbols.delete_forever_rounded,
                                label: l10n.deleteForever,
                                color: palette.mediaDanger,
                                onPressed: () => _confirmDeleteForever(context),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chrome(Widget child) {
    return IgnorePointer(
      ignoring: !_chromeVisible,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: _chromeVisible ? 1 : 0,
        child: child,
      ),
    );
  }

  Widget _buildMediaViewer(TrashFile file, AppLocalizations l10n) {

    const baseUrl = DataConstants.backendBaseUrl;
    final fullUrl = '$baseUrl/api/file/${file.id}/';

    if (file.isImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _chromeVisible = !_chromeVisible),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4.0,
          child: Center(child: AuthenticatedImage(imageUrl: fullUrl, fit: BoxFit.contain)),
        ),
      );
    }

    if (file.isVideo) {
      final insets = MediaQuery.paddingOf(context);
      return Padding(
        padding: EdgeInsets.only(top: insets.top + 64, bottom: insets.bottom + _bottomChromeHeight),
        child: VideoPlayerWidget(
          videoUrl: fullUrl,
          key: ValueKey(file.id),
          onControlsVisibilityChanged: (visible) {
            if (mounted) setState(() => _chromeVisible = visible);
          },
        ),
      );
    }

    final muted = context.palette.onMedia.withValues(alpha: 0.7);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Symbols.error_rounded, size: 64, color: muted),
          const SizedBox(height: 16),
          Text(
            l10n.fileTypeNotSupported,
            style: TextStyle(color: muted, fontSize: 16, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _subtitleFor(TrashFile file, AppLocalizations l10n) {
    if (!file.isVideo) return l10n.filePropertyTypeImage;
    final seconds = file.durationSeconds;
    if (seconds == null) return l10n.filePropertyTypeVideo;
    return '${l10n.filePropertyTypeVideo} · ${MediaThumbnail.formatDuration(Duration(seconds: seconds))}';
  }

  void _confirmRestore(BuildContext context) {
    final file = _currentFile;
    RestoreConfirmationDialog.show(
      context: context,
      fileCount: 1,
      onConfirm: () {
        context.read<TrashBloc>().add(RestoreFiles([file.id]));
        Navigator.pop(context); // Back to the trash list
      },
    );
  }

  void _confirmDeleteForever(BuildContext context) {
    final file = _currentFile;
    PermanentDeleteConfirmationDialog.show(
      context: context,
      fileCount: 1,
      onConfirm: () {
        context.read<TrashBloc>().add(PermanentlyDeleteFiles([file.id]));
        Navigator.pop(context); // Back to the trash list
      },
    );
  }
}

/// "Deleted in 12 days" pill over the dark viewer chrome.
class _CountdownPill extends StatelessWidget {
  final String label;
  final bool soon;

  const _CountdownPill({required this.label, required this.soon});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: (soon ? p.danger : p.onMedia).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: soon ? p.mediaDanger : p.onMedia),
      ),
    );
  }
}
