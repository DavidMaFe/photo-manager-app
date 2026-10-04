import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_sheet.dart';
import 'package:photo_manager_app/core/widgets/media_thumbnail.dart';
import 'package:photo_manager_app/core/widgets/status_chip.dart';
import 'package:photo_manager_app/features/gallery/domain/entities/gallery_file.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Properties of a file (status, capture date, duration, ID) in a bottom sheet.
/// Shared by the gallery and trash viewers.
class FilePropertiesSheet extends StatelessWidget {
  final GalleryFile file;

  /// Overrides the status chip (e.g. the trash countdown).
  final Widget? status;

  const FilePropertiesSheet({super.key, required this.file, this.status});

  static Future<void> show(BuildContext context, GalleryFile file, {Widget? status}) {
    return showAppSheet<void>(
      context,
      builder: (_) => FilePropertiesSheet(file: file, status: status),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = l10n.localeName;
    final capturedAt = file.capturedAt;
    final captured = capturedAt != null
        ? '${DateFormat.yMMMMEEEEd(locale).format(capturedAt)}, ${DateFormat.Hm(locale).format(capturedAt)}'
        : null;

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
      if (captured != null) _PropertyRow(label: l10n.filePropertyCapturedAt, value: captured),
      if (file.isVideo && file.durationSeconds != null)
        _PropertyRow(
          label: l10n.filePropertyDuration,
          value: MediaThumbnail.formatDuration(Duration(seconds: file.durationSeconds!)),
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
