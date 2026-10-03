import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_top_bar.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_management_feedback.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FileDetailPage extends StatefulWidget {

  final List<GalleryFile> files;
  final int initialIndex;
  final int? totalFilesCount;

  const FileDetailPage({
    super.key,
    required this.files,
    required this.initialIndex,
    this.totalFilesCount
  });

  @override
  State<FileDetailPage> createState() => _FileDetailPageState();
}


class _FileDetailPageState extends State<FileDetailPage> {

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

  GalleryFile get _currentFile => widget.files[_currentIndex];

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final palette = context.palette;
    final file = _currentFile;

    return BlocListener<FileManagementBloc, FileManagementState>(
      listener: _handleManagementState,
      child: Scaffold(
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
                    if (file.isPending) MediaViewerReviewPill(label: l10n.filterToReview),
                    MediaViewerIconButton(
                      icon: Symbols.info_rounded,
                      tooltip: l10n.viewerInfo,
                      onPressed: () => FilePropertiesSheet.show(context, file),
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
                            thumbnailBuilder: (context, index) => _thumbnail(widget.files[index]),
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
                                  icon: Symbols.cloud_upload_rounded,
                                  label: l10n.actionSave,
                                  highlighted: true,
                                  onPressed: () => _showManageModal(context),
                                ),
                              ),
                              const SizedBox(width: 8),
                              MediaViewerAction(
                                icon: Symbols.delete_rounded,
                                label: l10n.actionDelete,
                                color: palette.mediaDanger,
                                onPressed: () => _confirmDelete(context, l10n),
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
      ),
    );
  }

  /// Fades the viewer chrome in and out (a tap on the photo toggles it).
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

  Widget _buildMediaViewer(GalleryFile file, AppLocalizations l10n) {

    const baseUrl = DataConstants.backendBaseUrl;
    final fullUrl = '$baseUrl/api/file/${file.id}/';

    if (file.isImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _chromeVisible = !_chromeVisible),
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4.0,
          child: Center(
            child: AuthenticatedImage(
              imageUrl: fullUrl,
              fit: BoxFit.contain,
            ),
          ),
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
          }
        ),
      );
    }

    return _buildUnsupportedFileType(l10n);
  }

  Widget _thumbnail(GalleryFile file) {
    return AuthenticatedImage(
      imageUrl: '${DataConstants.backendBaseUrl}/api/file/${file.id}/thumbnail/',
      fit: BoxFit.cover,
      placeholder: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildUnsupportedFileType(AppLocalizations l10n) {
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
          )
        ],
      ),
    );
  }

  /// "Image" or "Video · 1:15".
  String _subtitleFor(GalleryFile file, AppLocalizations l10n) {
    if (!file.isVideo) return l10n.filePropertyTypeImage;
    final seconds = file.durationSeconds;
    if (seconds == null) return l10n.filePropertyTypeVideo;
    return '${l10n.filePropertyTypeVideo} · ${MediaThumbnail.formatDuration(Duration(seconds: seconds))}';
  }

  Future<void> _confirmDelete(BuildContext context, AppLocalizations l10n) async {
    final confirmed = await AppDialog.show(
      context: context,
      icon: Symbols.delete_rounded,
      tone: AppDialogTone.danger,
      title: l10n.deleteFileTitle,
      message: l10n.deleteFileBody,
      primaryLabel: l10n.actionDelete,
      secondaryLabel: l10n.cancel,
      destructive: true,
    );
    if (confirmed != true || !context.mounted) return;

    _dispatchDelete(context);
  }

  void _dispatchDelete(BuildContext context) {
    context.read<FileManagementBloc>().add(ManagedFilesRequested(
      fileIds: [_currentFile.id],
      action: const ManageAction(serverAction: ServerAction.delete, keepOnDevice: false),
    ));
  }

  /// Results of the delete action started from the viewer bar (the manage
  /// sheet handles its own results).
  Future<void> _handleManagementState(BuildContext context, FileManagementState state) async {
    if (ModalRoute.of(context)?.isCurrent != true) return;

    if (state is FileManagementSuccess) {
      await FileManagementFeedback.showSuccess(context, state);
      if (context.mounted) Navigator.pop(context, true);
    } else if (state is FileManagementPartialSuccess) {
      FileManagementFeedback.showPartialSuccess(context, state);
    } else if (state is FileManagementError) {
      FileManagementFeedback.showError(context, state, onRetry: () => _dispatchDelete(context));
    }
  }

  void _showManageModal(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      useSafeArea: true,
      context: context,
      isScrollControlled: true,
      // The sheet content draws its own surface and drag handle.
      backgroundColor: context.palette.surface.withValues(alpha: 0),
      showDragHandle: false,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FileManagementBloc>()),
          BlocProvider.value(value: context.read<ManageFolderBloc>())
        ],
        child: ManageFileModal(fileIds: [_currentFile.id], isMultiple: false),
      )
    );

    // If the file was successfully managed (deleted, moved, etc.), close the detail page
    // and return to the previous page (gallery or folder content)
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}
