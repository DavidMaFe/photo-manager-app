import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';
import 'package:photo_manager_app/features/trash/domain/entities/trash_file.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_bloc.dart';
import 'package:photo_manager_app/features/trash/presentation/bloc/trash_event.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/permanent_delete_confirmation_dialog.dart';
import 'package:photo_manager_app/features/trash/presentation/widgets/dialogs/restore_confirmation_dialog.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


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

  late PageController _pageController;
  late int _currentIndex;
  bool _videoControlsVisible = true;

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context, l10n),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.files.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final file = widget.files[index];
          return _buildMediaViewerWithOverlay(file, l10n);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.fileCountLabel(_currentIndex + 1, widget.files.length),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15
        ),
      ),
      actions: [
        _buildDaysRemainingBadge(l10n),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showOptionsMenu(context, l10n),
        )
      ],
    );
  }

  Widget _buildDaysRemainingBadge(AppLocalizations l10n) {
    final daysRemaining = _currentFile.daysUntilPermanentDeletion;
    final isImminent = _currentFile.isDeletionImminent;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isImminent ? Colors.red : Colors.orange,
          borderRadius: BorderRadius.circular(12)
        ),
        child: Text(
          l10n.daysRemaining(daysRemaining),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );
  }

  Widget _buildMediaViewer(TrashFile file, AppLocalizations l10n) {

    const baseUrl = DataConstants.backendBaseUrl;
    final fullUrl = '$baseUrl/api/file/${file.id}/';

    if (file.isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Container(
          color: Colors.black,
          child: Center(
            child: AuthenticatedImage(
              imageUrl: fullUrl,
              fit: BoxFit.cover,
            ),
          )
        ),
      );
    } else if (file.isVideo) {
      return Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: VideoPlayerWidget(
          videoUrl: fullUrl,
          key: ValueKey(file.id),
          onControlsVisibilityChanged: (visible) {
            setState(() {
              _videoControlsVisible = visible;
            });
          }
        ),
      );
    } else {
     return _buildUnsupportedFileType(l10n);
    }
  }

  Widget _buildMediaViewerWithOverlay(TrashFile file, AppLocalizations l10n) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _buildMediaViewer(file, l10n),
        _buildFloatingActionsPositioned(file, context, l10n)
      ],
    );
  }

  Widget _buildFloatingActionsPositioned(TrashFile file, BuildContext context, AppLocalizations l10n) {
    if (file.isVideo && !_videoControlsVisible) {
      return const SizedBox.shrink();
    }

    final bottomOffset = file.isVideo ? 80.0 : 40.0;

    return Positioned(
      bottom: bottomOffset,
      left: 20,
      right: 20,
      child: _buildFloatingActions(context, l10n),
    );
  }

  Widget _buildFloatingActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRestoreButton(context, l10n),
        _buildDeletePermanentlyButton(context, l10n)
      ],
    );
  }

  Widget _buildRestoreButton(BuildContext context, AppLocalizations l10n) {
    return _buildFloatingActionButton(
      Icons.restore,
      () => _showRestoreConfirmation(context, l10n)
    );
  }

  Widget _buildDeletePermanentlyButton(BuildContext context, AppLocalizations l10n) {
    return _buildFloatingActionButton(
      Icons.delete_forever,
      () => _showDeletePermanentlyConfirmation(context, l10n)
    );
  }

  Widget _buildFloatingActionButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.4),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2)
              )
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  Widget _buildUnsupportedFileType(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.white.withValues(alpha: 0.7)
          ),
          const SizedBox(height: 16),
          Text(
            l10n.fileTypeNotSupported,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16
            ),
            textAlign: TextAlign.center,
          )
        ],
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => RestoreConfirmationDialog(
        fileCount: 1,
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          context.read<TrashBloc>().add(RestoreFiles([_currentFile.id]));
          Navigator.pop(context); // Close detail page and go back to trash
        },
      ),
    );
  }

  void _showDeletePermanentlyConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => PermanentDeleteConfirmationDialog(
        fileCount: 1,
        onConfirm: () {
          Navigator.of(dialogContext).pop();
          context.read<TrashBloc>().add(PermanentlyDeleteFiles([_currentFile.id]));
          Navigator.pop(context); // Close detail page and go back to trash
        },
      ),
    );
  }

  void _showOptionsMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.fileProperties),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(context, l10n);
              },
            ),
          ],
        ),
      )
    );
  }

  void _showDetailsDialog(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                Colors.grey.shade50
              ]
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: PhotoManagerColors.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)
                  )
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: PhotoManagerColors.primary,
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Icon(
                        _currentFile.isImage ? Icons.image : Icons.videocam,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.fileProperties,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _currentFile.isImage ? l10n.filePropertyTypeImage : l10n.filePropertyTypeVideo,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600
                            ),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    _buildModernDetailRow(
                      icon: Icons.calendar_today,
                      label: l10n.filePropertyCapturedAt,
                      value: _formatDate(_currentFile.capturedAt, l10n)
                    ),

                    if(_currentFile.isVideo && _currentFile.durationSeconds != null) ...[
                      const SizedBox(height: 16),
                      _buildModernDetailRow(
                          icon: Icons.access_time,
                          label: l10n.filePropertyDuration,
                          value: _formatDuration(_currentFile.durationSeconds!)
                      ),
                    ],

                    const SizedBox(height: 16),
                    _buildModernDetailRow(
                        icon: Icons.fingerprint,
                        label: 'ID',
                        value: _currentFile.id,
                        isMonospace: true
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: PhotoManagerColors.primary.withValues(alpha: 0.1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                    ),
                    child: Text(
                      l10n.close,
                      style: const TextStyle(
                        color: PhotoManagerColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 16
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool showBadge = false,
    bool isMonospace = false
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8)
            ),
            child: Icon(
              icon,
              size: 20,
              color: PhotoManagerColors.primary
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500
                  ),
                ),
                const SizedBox(height: 4),
                showBadge
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: (valueColor ?? Colors.grey).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6)
                        ),
                        child: Text(
                          value,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: valueColor ?? Colors.black87
                          ),
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: valueColor ?? Colors.black87,
                          fontFamily: isMonospace ? 'monospace' : null
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
              ],
            ),
          )
        ],
      ),
    );
  }

  String _formatDate(DateTime date, AppLocalizations l10n) {

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {

        if(difference.inMinutes == 1) {
          return l10n.timePassedInMinutesSingular;
        } else {
          return l10n.timePassedInMinutesPlural(difference.inMinutes);
        }
      }

      if(difference.inHours == 1) {
        return l10n.timePassedInHoursSingular;
      } else {
        return l10n.timePassedInHoursPlural(difference.inHours);
      }
    } else if (difference.inDays < 7) {

      if(difference.inDays == 1) {
        return l10n.timePassedInDaysSingular;
      } else {
        return l10n.timePassedInDaysPlural(difference.inDays);
      }
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final remainingSeconds = duration.inSeconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
