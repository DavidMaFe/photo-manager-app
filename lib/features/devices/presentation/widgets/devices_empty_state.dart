import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DevicesEmptyState extends StatelessWidget {
  const DevicesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.devices_outlined,
              size: 80,
              color: context.palette.ink3,
            ),
            const SizedBox(height: 24),
            Text(
              l10n.noDevices,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: context.palette.ink,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.noDevicesDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: context.palette.ink2,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
