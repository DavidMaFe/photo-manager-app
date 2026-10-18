import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/app_config.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/date_formatter.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/features/downloads/domain/entities/remote_media_file.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_bloc.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/download_progress_event.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/on_device_presence_cubit.dart';
import 'package:photo_manager_app/features/downloads/presentation/bloc/share_cubit.dart';
import 'package:photo_manager_app/core/widgets/app_dialog.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/encrypted_image.dart';
import 'package:photo_manager_app/features/encrypted_media/presentation/widgets/zoomable_encrypted_photo.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_action_bar.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_thumbnail_strip.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_layout.dart';
import 'package:photo_manager_app/core/widgets/media_viewer/media_viewer_top_bar.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/manage_action.dart';
import 'package:photo_manager_app/features/file_management/domain/enums/server_action.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_state.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_management_feedback.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/file_properties_sheet.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/favorites/presentation/widgets/favorite_viewer_button.dart';
import 'package:photo_manager_app/features/file_management/presentation/models/album_viewer_context.dart';
import 'package:photo_manager_app/features/folders/presentation/widgets/cover_picker_sheet.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FileDetailPage extends StatefulWidget {

  final List<GalleryFile> files;
  final int initialIndex;
  final int? totalFilesCount;

  /// Opened from an album: album path in the header, "Cover of…" pill and
  /// Cover / Move in the bar.
  final AlbumViewerContext? albumContext;

  const FileDetailPage({
    super.key,
    required this.files,
    required this.initialIndex,
    this.totalFilesCount,
    this.albumContext
  });

  @override
  State<FileDetailPage> createState() => _FileDetailPageState();
}


class _FileDetailPageState extends State<FileDetailPage> {

  late PageController _pageController;
  late int _currentIndex;
  bool _chromeVisible = true;

  /// Albums each file is a cover of after changing them here.
  final Map<String, List<String>> _coverOfOverrides = {};

  AlbumViewerContext? get _albumContext =>
      AppConfig.favoritesAndCoversEnabled ? widget.albumContext : null;

  List<String> _coverOf(GalleryFile file) => _coverOfOverrides[file.id] ?? file.coverOf;

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
        body: MediaViewerLayout(
          chromeVisible: _chromeVisible,
          media: PageView.builder(
            controller: _pageController,
            itemCount: widget.files.length,
            // Moving to another file keeps the chrome as it is (full screen or not)
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => _buildMediaViewer(widget.files[index], l10n),
          ),
          top: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MediaViewerTopBar(
                title: file.capturedAt != null
                    ? DateFormatter.formatDayAndTime(file.capturedAt!, context)
                    : l10n.noDate,
                subtitle: _albumContext?.path ?? _subtitleFor(file, l10n, context),
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
              if (_albumContext != null && _coverOf(file).isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: MediaViewerCoverPill(label: _coverPillLabel(_coverOf(file), l10n)),
                ),
            ],
          ),
          bottom: MediaViewerBottomPanel(
            strip: widget.files.length > 1
                ? MediaViewerThumbnailStrip(
                    itemCount: widget.files.length,
                    currentIndex: _currentIndex,
                    thumbnailBuilder: (context, index) => _thumbnail(widget.files[index]),
                    onSelected: (index) => _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeOut,
                    ),
                  )
                : null,
            actions: _albumContext != null
                ? _buildAlbumActionBar(context, file, l10n, palette)
                : _buildGalleryActionBar(context, file, l10n, palette),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaViewer(GalleryFile file, AppLocalizations l10n) {

    if (file.isImage) {
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => setState(() => _chromeVisible = !_chromeVisible),
        child: ZoomableEncryptedPhoto(fileId: file.id, hasPreview: file.hasPreview),
      );
    }

    if (file.isVideo) {
      return VideoPlayerWidget(
        fileId: file.id,
        key: ValueKey(file.id),
        onControlsVisibilityChanged: (visible) {
          if (mounted) setState(() => _chromeVisible = visible);
        },
      );
    }

    return _buildUnsupportedFileType(l10n);
  }

  Widget _thumbnail(GalleryFile file) {
    return EncryptedImage(fileId: file.id, transparentWhileLoading: true);
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

  /// The device it comes from and its size («Galaxy S23 · 4,2 MB»); «Image» or «Video · 1:15» when the device is not
  /// known.
  String _subtitleFor(GalleryFile file, AppLocalizations l10n, BuildContext context) {
    final size = file.sizeBytes > 0
        ? ' · ${FileSizeFormatter.format(file.sizeBytes, locale: Localizations.localeOf(context).toLanguageTag())}'
        : '';
    if (file.deviceName case final device?) return '$device$size';
    if (!file.isVideo) return '${l10n.filePropertyTypeImage}$size';
    final seconds = file.durationSeconds;
    if (seconds == null) return '${l10n.filePropertyTypeVideo}$size';
    return '${l10n.filePropertyTypeVideo} · ${MediaThumbnail.formatDuration(Duration(seconds: seconds))}';
  }

  /// Whether this phone has the file; null while it is not known.
  bool? _isOnDevice(BuildContext context, GalleryFile file) =>
      context.select<OnDevicePresenceCubit, bool?>((cubit) => cubit.state.isOnDevice(file.id));

  /// «On phone» (dimmed) when this phone has it; «Download» otherwise.
  Widget _downloadAction(BuildContext context, GalleryFile file, AppLocalizations l10n) {
    final onDevice = _isOnDevice(context, file) ?? false;
    return MediaViewerAction(
      icon: onDevice ? Symbols.download_done_rounded : Symbols.download_rounded,
      label: onDevice ? l10n.actionOnDevice : l10n.actionDownload,
      onPressed: onDevice
          ? null
          : () => context.read<DownloadProgressBloc>().add(DownloadFilesRequested({file.id})),
    );
  }

  void _share(BuildContext context, GalleryFile file) {
    context.read<ShareCubit>().share([RemoteMediaFile(id: file.id, type: file.type, sizeBytes: file.sizeBytes)]);
  }

  /// Gallery bar: Share · Favorite · Save · On phone/Download · Delete.
  Widget _buildGalleryActionBar(BuildContext context, GalleryFile file, AppLocalizations l10n, AppPalette palette) {
    return MediaViewerActionBar(
      children: [
        Expanded(
          child: MediaViewerAction(
            icon: Symbols.ios_share_rounded,
            label: l10n.actionShare,
            onPressed: () => _share(context, file),
          ),
        ),
        if (AppConfig.favoritesAndCoversEnabled)
          Expanded(child: FavoriteViewerButton(key: ValueKey('favorite-${file.id}'), file: file)),
        Expanded(
          child: MediaViewerAction(
            icon: Symbols.cloud_upload_rounded,
            label: l10n.actionSave,
            highlighted: true,
            onPressed: () => _showManageModal(context),
          ),
        ),
        Expanded(child: _downloadAction(context, file, l10n)),
        Expanded(
          child: MediaViewerAction(
            icon: Symbols.delete_rounded,
            label: l10n.actionDelete,
            color: palette.mediaDanger,
            onPressed: () => _confirmDelete(context, l10n),
          ),
        ),
      ],
    );
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

  /// Album bar: Favorite · Cover (photos only) · Share · On phone/Download · More (Move, Delete).
  Widget _buildAlbumActionBar(BuildContext context, GalleryFile file, AppLocalizations l10n, AppPalette palette) {
    return MediaViewerActionBar(
      children: [
        Expanded(child: FavoriteViewerButton(key: ValueKey('favorite-${file.id}'), file: file)),
        if (file.isImage)
          Expanded(
            child: MediaViewerCoverAction(
              label: l10n.cover,
              isCover: _coverOf(file).isNotEmpty,
              onPressed: () => _openCoverPicker(context, file),
            ),
          ),
        Expanded(
          child: MediaViewerAction(
            icon: Symbols.ios_share_rounded,
            label: l10n.actionShare,
            onPressed: () => _share(context, file),
          ),
        ),
        Expanded(child: _downloadAction(context, file, l10n)),
        Expanded(
          child: MediaViewerMoreAction(
            label: l10n.actionMore,
            items: [
              MediaViewerMenuItem(
                icon: Symbols.drive_file_move_rounded,
                label: l10n.move,
                onSelected: () => _showManageModal(context, initialOption: ManageOption.album),
              ),
              MediaViewerMenuItem(
                icon: Symbols.delete_rounded,
                label: l10n.actionDelete,
                destructive: true,
                onSelected: () => _confirmDelete(context, l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// «Cover of Playa», or «Cover of 2 albums» (also when the album's name is not known here).
  String _coverPillLabel(List<String> coverOf, AppLocalizations l10n) {
    final name = coverOf.length == 1 ? _albumContext?.nameOf(coverOf.single) : null;
    return name != null ? l10n.coverOf(name) : l10n.coverOfMany(coverOf.length);
  }

  Future<void> _openCoverPicker(BuildContext context, GalleryFile file) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await CoverPickerSheet.show(context, [file.id]);
    if (!context.mounted || result is! CoversSaved) return;

    // Keep the pill right without reloading the album: update where this file is a cover.
    final coverOf = {..._coverOf(file)};
    for (final folder in result.folders) {
      if (folder.covers.any((cover) => cover.fileId == file.id)) {
        coverOf.add(folder.folderId);
      } else {
        coverOf.remove(folder.folderId);
      }
    }
    setState(() => _coverOfOverrides[file.id] = coverOf.toList());
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.coverUpdated(result.changedAlbums))));
  }

  void _showManageModal(BuildContext context, {ManageOption initialOption = ManageOption.saveAndFree}) async {
    final result = await ManageFileModal.show(
      context,
      fileIds: [_currentFile.id],
      totalSizeBytes: _currentFile.sizeBytes,
      initialOption: initialOption,
    );

    // If the file was successfully managed (deleted, moved, etc.), close the detail page
    // and return to the previous page (gallery or folder content)
    if (result == true && context.mounted) {
      Navigator.pop(context, true);
    }
  }
}
