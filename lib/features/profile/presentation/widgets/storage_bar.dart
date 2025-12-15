import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/profile/domain/entities/user_profile.dart';


class StorageBar extends StatelessWidget {

  final UserProfile profile;

  const StorageBar({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {

    final usedGb = profile.storageUsedGb;
    final totalGb = profile.storageTotalGb;
    final percentage = profile.storageUsedPercentage;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Storage',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87
              ),
            ),
            Text(
              '${usedGb.toStringAsFixed(1)} / ${totalGb.toStringAsFixed(0)} GB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600]
              ),
            )
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getStorageColor(percentage)
            ),
          ),
        )
      ],
    );
  }

  Color _getStorageColor(double percentage) {
    if (percentage < 0.5) {
      return Colors.blue;
    } else if (percentage < 0.75) {
      return Colors.orange;
    } else if (percentage < 0.9) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}