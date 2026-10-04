import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/errors/helper/failure_message_helper.dart';
import 'package:photo_manager_app/core/injection_container.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/core/widgets/app_button.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/file_management/domain/entities/file_info.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_bloc.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_event.dart';
import 'package:photo_manager_app/features/file_management/presentation/bloc/file_info/file_info_state.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Properties of a file in a bottom sheet. Shared by the gallery and trash viewers.
///
/// The properties already known ([file]) show right away; the rest (name, size,
/// dimensions, upload date, album, device) come from [FileInfoBloc]. Rows
/// without data are hidden.
class FilePropertiesSheet extends StatelessWidget {
  final GalleryFile file;

  /// Overrides the status chip (e.g. the trash countdown).
  final Widget? status;

  const FilePropertiesSheet({super.key, required this.file, this.status});

  static Future<void> show(BuildContext context, GalleryFile file, {Widget? status}) {
    return showAppSheet<void>(
      context,
      builder: (_) => BlocProvider(
        create: (_) => sl<FileInfoBloc>()..add(LoadFileInfo(file.id)),
        child: FilePropertiesSheet(file: file, status: status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FileInfoBloc, FileInfoState>(
      builder: (context, state) => _buildContent(context, state),
    );
  }

  Widget _buildContent(BuildContext context, FileInfoState state) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = l10n.localeName;
    final FileInfo? info = state is FileInfoLoaded ? state.info : null;

    String dateAndTime(DateTime date) => '${DateFormat.yMMMMEEEEd(locale).format(date)}, ${DateFormat.Hm(locale).format(date)}';

    final capturedAt = info?.capturedAt ?? file.capturedAt;
    final uploadedAt = info?.uploadedAt;
    final sizeBytes = info != null && info.sizeBytes > 0 ? info.sizeBytes : file.sizeBytes;
    final durationSeconds = info?.durationSeconds ?? file.durationSeconds;

    final rows = <Widget>[
      _PropertyRow(
        label: l10n.filePropertyStatus,
        child: status ??
            StatusChip(
              compact: true,
              label: file.isPending ? l10n.filterToReview : l10n.statusSafe,
              icon: file.isPending ? Symbols.schedule_rounded : Symbols.cloud_done_rounded,
              variant: file.isPending ? StatusChipVariant.review : StatusChipVariant.safe,
            ),
      ),
      if (info?.originalFilename case final name? when name.isNotEmpty)
        _PropertyRow(label: l10n.filePropertyName, value: name),
      if (capturedAt != null) _PropertyRow(label: l10n.filePropertyCapturedAt, value: dateAndTime(capturedAt)),
      if (uploadedAt != null) _PropertyRow(label: l10n.filePropertyUploadedAt, value: dateAndTime(uploadedAt)),
      if (sizeBytes > 0)
        _PropertyRow(label: l10n.filePropertySize, value: FileSizeFormatter.format(sizeBytes, locale: locale)),
      if (info != null && info.hasDimensions)
        _PropertyRow(label: l10n.filePropertyDimensions, value: '${info.width} × ${info.height}'),
      if (file.isVideo && durationSeconds != null)
        _PropertyRow(
          label: l10n.filePropertyDuration,
          value: MediaThumbnail.formatDuration(Duration(seconds: durationSeconds)),
        ),
      if (info?.folderName case final album? when album.isNotEmpty)
        _PropertyRow(label: l10n.filePropertyAlbum, value: album),
      if (info?.deviceName case final device? when device.isNotEmpty)
        _PropertyRow(label: l10n.filePropertyDevice, value: device),
      if (state is FileInfoLoading) const _LoadingRow(),
      if (state is FileInfoError)
        _ErrorRow(
          message: FailureMessageHelper.getMessage(context, state.failure),
          onRetry: () => context.read<FileInfoBloc>().add(LoadFileInfo(file.id)),
        ),
      _PropertyRow(
        label: 'ID',
        value: file.id,
        monospace: true,
        trailing: IconButton(
          tooltip: l10n.copyId,
          icon: Icon(Symbols.content_copy_rounded, size: 20, color: p.ink2),
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: file.id));
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copiedToClipboard)));
          },
        ),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(l10n.fileProperties, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const Divider(),
          rows[i],
        ],
      ],
    );
  }
}

class _PropertyRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? child;
  final Widget? trailing;
  final bool monospace;

  const _PropertyRow({
    required this.label,
    this.value,
    this.child,
    this.trailing,
    this.monospace = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 56),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: child ??
                  SelectableText(
                    value ?? '',
                    style: TextStyle(
                      fontSize: monospace ? 13 : 14,
                      fontWeight: FontWeight.w600,
                      color: p.ink,
                      fontFamily: monospace ? 'monospace' : null,
                      // iOS has no generic "monospace" family.
                      fontFamilyFallback: monospace ? const ['Menlo', 'Courier'] : null,
                    ),
                  ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// Placeholder while the extra properties load.
class _LoadingRow extends StatelessWidget {
  const _LoadingRow();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Semantics(
      liveRegion: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Row(
          children: [
            const SizedBox.square(dimension: 18, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 12),
            Text(
              l10n.fileInfoLoading,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
            ),
          ],
        ),
      ),
    );
  }
}

/// The extra properties could not load: message and retry.
class _ErrorRow extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorRow({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(Symbols.error_rounded, size: 20, color: p.dangerInk),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
            ),
          ),
          const SizedBox(width: 8),
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
