import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/utils/file_size_formatter.dart';
import 'package:photo_manager_app/features/profile/domain/entities/storage_usage.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// "Storage — 12.4 GB of 50 GB" with the usage bar: split into photos, videos
/// and trash with a legend when the server sends the breakdown, or a single
/// color otherwise.
class StorageBar extends StatelessWidget {

  final UserProfile profile;

  const StorageBar({super.key, required this.profile});

  /// "12.4 GB" (one decimal below 100 GB) in the user's locale.
  static String formatGb(double gb, String locale) {
    final pattern = gb >= 100 || gb == gb.roundToDouble() ? '#,##0' : '#,##0.0';
    return '${NumberFormat(pattern, locale).format(gb)} GB';
  }

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final used = formatGb(profile.storageUsedGb, l10n.localeName);
    final total = formatGb(profile.storageTotalGb, l10n.localeName);
    final storageText = l10n.storageOf(used, total);
    final usedIndex = storageText.indexOf(used);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Expanded(
              child: Text(
                l10n.storage,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink),
              ),
            ),
            Text.rich(
              TextSpan(
                children: usedIndex < 0
                    ? [TextSpan(text: storageText)]
                    : [
                        TextSpan(text: storageText.substring(0, usedIndex)),
                        TextSpan(text: used, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
                        TextSpan(text: storageText.substring(usedIndex + used.length)),
                      ],
              ),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: p.ink2),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (profile.storage case final storage?)
          _BreakdownBar(storage: storage)
        else
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: profile.storageUsedPercentage.clamp(0.0, 1.0),
              minHeight: 10,
              backgroundColor: p.surface2,
              valueColor: AlwaysStoppedAnimation<Color>(p.accent),
            ),
          ),
      ],
    );
  }
}


/// One part of the storage breakdown.
typedef _Segment = ({String label, int bytes, Color color});


/// Segmented bar (photos, videos, trash over the quota) and its legend.
class _BreakdownBar extends StatelessWidget {
  static const double gap = 2;

  final StorageUsage storage;

  const _BreakdownBar({required this.storage});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;
    final locale = l10n.localeName;
    final List<_Segment> segments = [
      (label: l10n.photos, bytes: storage.photosBytes, color: p.accent),
      (label: l10n.videos, bytes: storage.videosBytes, color: p.review),
      (label: l10n.trash, bytes: storage.trashBytes, color: p.ink3),
    ];
    final visible = segments.where((s) => s.bytes > 0).toList();
    String describe(_Segment s) => '${s.label} ${FileSizeFormatter.format(s.bytes, locale: locale)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: segments.map(describe).join(', '),
          excludeSemantics: true,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: SizedBox(
              height: 10,
              child: ColoredBox(
                color: p.surface2,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final gaps = gap * (visible.length > 1 ? visible.length - 1 : 0);
                    return Row(
                      children: [
                        for (var i = 0; i < visible.length; i++) ...[
                          if (i > 0) const SizedBox(width: gap),
                          SizedBox(
                            width: ((width - gaps) * storage.fractionOf(visible[i].bytes))
                                .clamp(0.0, width - gaps),
                            child: ColoredBox(color: visible[i].color),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        ExcludeSemantics(
          child: Wrap(
            spacing: 16,
            runSpacing: 6,
            children: [
              for (final segment in segments)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: segment.color, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      describe(segment),
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
