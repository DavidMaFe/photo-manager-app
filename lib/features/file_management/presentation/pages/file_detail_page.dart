import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/config/data_constants.dart';
import 'package:photo_manager_app/config/theme/photo_manager_colors.dart';
import 'package:photo_manager_app/core/widgets/authenticated_image.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_management/file_management_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/manage_folder/manage_folder_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/widgets/manage_file_modal.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/features/gallery/presentation/widgets/video_player_widget.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


class FileDetailPage extends StatefulWidget {

  final List<GalleryFile> files;
  final int initialIndex;

  const FileDetailPage({
    super.key,
    required this.files,
    required this.initialIndex
  });

  @override
  State<FileDetailPage> createState() => _FileDetailPageState();
}


class _FileDetailPageState extends State<FileDetailPage> {

  late PageController _pageController;
  late int _currentIndex;

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _buildAppBar(context, l10n),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.files.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final file = widget.files[index];
                return _buildMediaViewer(file, l10n);
              },
            ),
          ),
          _buildFileInfo(context, l10n),
          if(_currentFile.isPending) _buildManageButton(context, l10n)
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, AppLocalizations l10n) {
    return AppBar(
      backgroundColor: Colors.black.withValues(alpha: 0.7),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        l10n.fileCountLabel(_currentIndex + 1, widget.files.length),
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        if (_currentFile.isPending)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(12)
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.schedule, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    l10n.pendingSingular,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ],
              ),
            ),
          ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () => _showOptionsMenu(context, l10n),
        )
      ],
    );
  }

  Widget _buildMediaViewer(GalleryFile file, AppLocalizations l10n) {

    final baseUrl = DataConstants.backendBaseUrl;
    final fullUrl = '$baseUrl/api/file/${file.id}/';

    if (file.isImage) {
      return InteractiveViewer(
        minScale: 0.5,
        maxScale: 4.0,
        child: Center(
          child: AuthenticatedImage(
            imageUrl: fullUrl,
            fit: BoxFit.contain,
          )
        ),
      );
    } else if (file.isVideo) {
      return VideoPlayerWidget(
        videoUrl: fullUrl,
        key: ValueKey(file.id)
      );
    } else {
     return _buildUnsupportedFileType(l10n);
    }
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

  Widget _buildFileInfo(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16))
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _currentFile.isImage ? l10n.filePropertyTypeImage : l10n.filePropertyTypeVideo,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoItem(Icons.calendar_today, _formDate(_currentFile.capturedAt, l10n)),
              const SizedBox(width: 24),
              if (_currentFile.isVideo && _currentFile.durationSeconds != null)
                _buildInfoItem(Icons.access_time, _formatDuration(_currentFile.durationSeconds!))
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildInfoItem(Icons.label, _currentFile.isPending ? l10n.filePropertyStatusPending : l10n.filePropertyStatusManaged)
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12
          ),
        )
      ],
    );
  }
  
  Widget _buildManageButton(BuildContext context, AppLocalizations l10n) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        onPressed: () => _showManageModal(context),
        icon: const Icon(Icons.settings),
        label: Text(l10n.fileDetailManageFile),
        style: ElevatedButton.styleFrom(
          backgroundColor: PhotoManagerColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)
          )
        ),
      ),
    );
  }
  
  void _showManageModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FileManagementBloc>()),
          BlocProvider.value(value: context.read<ManageFolderBloc>())
        ],
        child: ManageFileModal(fileIds: [_currentFile.id], isMultiple: false),
      )
    ).then((_) {
      if (!context.mounted) return;
      Navigator.pop(context, true);
    });
  }

  void _showOptionsMenu(BuildContext context, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: Text(l10n.fileShare),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar compartir
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: Text(l10n.fileDownload),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implementar descarga
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(l10n.fileProperties),
              onTap: () {
                Navigator.pop(context);
                _showDetailsDialog(context, l10n);
              },
            ),
            if (_currentFile.isPending)
              ListTile(
                leading: const Icon(Icons.settings, color: Colors.blue),
                title: Text(l10n.fileDetailManageFile, style: TextStyle(color: Colors.blue)),
                onTap: () {
                  Navigator.pop(context);
                  _showManageModal(context);
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
      builder: (context) => AlertDialog(
        title: Text(l10n.fileProperties),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(l10n.filePropertyType, _currentFile.isImage ? l10n.filePropertyTypeImage : l10n.filePropertyTypeVideo),
            _buildDetailRow(l10n.filePropertyStatus, _currentFile.isPending ? l10n.filePropertyStatusPending :  l10n.filePropertyStatusManaged),
            _buildDetailRow(l10n.filePropertyCapturedAt, _formDate(_currentFile.capturedAt, l10n)),
            if(_currentFile.isVideo && _currentFile.durationSeconds != null)
              _buildDetailRow(l10n.filePropertyDuration, _formatDuration(_currentFile.durationSeconds!)),
            _buildDetailRow('ID', _currentFile.id)
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          )
        ],
      )
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          )
        ],
      ),
    );
  }

  String _formDate(DateTime date, AppLocalizations l10n) {

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