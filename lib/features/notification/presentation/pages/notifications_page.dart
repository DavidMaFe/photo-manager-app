
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class NotificationsPage extends StatelessWidget {

  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        backgroundColor: context.palette.surface,
      ),
      body: _buildContent(context, l10n),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return _buildEmptyState(context, l10n);
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: context.palette.ink3,
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emptyNotifications,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: context.palette.ink
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(
              fontSize: 15,
              color: context.palette.ink2
            ),
          )
        ],
      ),
    );
  }
}