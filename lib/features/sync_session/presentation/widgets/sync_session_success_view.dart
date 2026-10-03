import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager_app/features/sync_session/domain/entities/sync_result.dart';

import '../../../../l10n/app_localizations.dart';


class SyncSessionSuccessView extends StatelessWidget {

  final SyncResult result;

  const SyncSessionSuccessView({super.key, required this.result});

  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    final isFullSuccess = result.isSuccess;
    final iconColor = isFullSuccess ? context.palette.safe : context.palette.review;
    final icon = isFullSuccess ? Icons.check_circle : Icons.info_outline;
    final title = isFullSuccess ? l10n.syncSessionCompleted : l10n.syncSessionFinished;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 100,
            color: iconColor,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: context.palette.ink
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: context.palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.palette.line,
                width: 1
              )
            ),
            child: Column(
              children: [
                _buildStatRow(context, label: l10n.total, value: l10n.infoFiles(result.totalFiles), color: context.palette.ink2),
                const SizedBox(height: 16),
                _buildStatRow(context, label: l10n.uploaded, value: l10n.infoFiles(result.uploadedFiles), color: context.palette.safe),

                if (result.failedFiles > 0) ...[
                  const SizedBox(height: 16),
                  _buildStatRow(context, label: l10n.failed, value: l10n.infoFiles(result.failedFiles), color: context.palette.danger),
                ]
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: context.palette.accent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: Text(l10n.goBack, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.onAccent
              )),
            )
          )
        ],
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, {required String label, required String value, required Color color}) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(
          fontSize: 16,
          color: context.palette.ink2
        )),
        Text(value, style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: color
        ))
      ],
    );
  }
}