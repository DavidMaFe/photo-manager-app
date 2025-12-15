import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';

import '../../../../l10n/app_localizations.dart';


class ProfileStats extends StatelessWidget {
  
  final UserProfile profile;
  
  const ProfileStats({super.key, required this.profile});
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _StatItem(
          value: _formatNumber(profile.fileCount),
          label: l10n.files,
          onTap: () {},
        ),
        _buildDivider(),
        _StatItem(
          value: _formatNumber(profile.folderCount),
          label: l10n.folders,
          onTap: () {},
        ),
        _buildDivider(),
        _StatItem(
          value: _formatNumber(profile.deviceCount),
          label: l10n.devices,
          onTap: () {},
        )
      ],
    );
  }
  
  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.grey[300]
    );
  }
  
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]}'
    );
  }
}


class _StatItem extends StatelessWidget {

  final String value;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({required this.value, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsetsGeometry.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600]
              ),
            )
          ],
        ),
      ),
    );
  }
}