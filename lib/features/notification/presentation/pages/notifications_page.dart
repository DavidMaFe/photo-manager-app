
import 'package:flutter/cupertino.dart';
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
      ),
      body: _buildContent(context, l10n),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    return _buildEmptyState(l10n);
  }

  Widget _buildEmptyState(AppLocalizations l10n) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 24),
          Text(
            l10n.emptyNotifications,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800]
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[600]
            ),
          )
        ],
      ),
    );
  }
}