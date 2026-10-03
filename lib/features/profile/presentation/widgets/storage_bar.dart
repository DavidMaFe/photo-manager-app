import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// "Storage — 12.4 GB of 50 GB" with a single-color usage bar.
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
