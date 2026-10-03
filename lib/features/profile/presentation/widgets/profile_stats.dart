import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';


/// Items, albums and devices counts in three left-aligned columns.
class ProfileStats extends StatelessWidget {

  final UserProfile profile;

  const ProfileStats({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final number = NumberFormat.decimalPattern(l10n.localeName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _StatItem(value: number.format(profile.fileCount), label: l10n.elementsLabel(profile.fileCount))),
        Expanded(child: _StatItem(value: number.format(profile.folderCount), label: l10n.albumsLabel(profile.folderCount))),
        Expanded(child: _StatItem(value: number.format(profile.deviceCount), label: l10n.devicesLabel(profile.deviceCount))),
      ],
    );
  }
}


class _StatItem extends StatelessWidget {

  final String value;
  final String label;

  const _StatItem({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: p.ink)),
        Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2)),
      ],
    );
  }
}
