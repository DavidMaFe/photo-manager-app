import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_bloc.dart';
import 'package:photo_manager_app/features/sync_session/presentation/bloc/sync_session_event.dart';

import '../../../../l10n/app_localizations.dart';


class SyncSessionUploadingFiles extends StatelessWidget {
  
  final int uploadCount;
  final int totalCount;
  
  const SyncSessionUploadingFiles({super.key, required this.uploadCount,
    required this.totalCount});
  
  double get progress {
    if (totalCount == 0) return 0.0;
    return uploadCount / totalCount;
  }
  
  int get progressPercentage => (progress * 100).round();
  
  @override
  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context)!;
    
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_upload_outlined,
            size: 80,
            color: context.palette.accent
          ),
          const SizedBox(height: 32),
          Text(l10n.syncSessionUploadingFiles, style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: context.palette.ink
          )),
          const SizedBox(height: 40),
          
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: context.palette.line,
              valueColor: AlwaysStoppedAnimation<Color>(context.palette.safe),
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.syncSessionFiles(totalCount, uploadCount),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: context.palette.ink
                ),
              ),
              
              Text('$progressPercentage%', style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: context.palette.accentInk
              ))
            ],
          ),
          const SizedBox(height: 48),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showCancelConfirmationDialog(context, l10n);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: context.palette.danger, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
              child: Text(l10n.syncSessionCancel, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: context.palette.danger
              )),
            ),
          )
        ],
      ),
    );
  }
  
  Future<void> _showCancelConfirmationDialog(BuildContext context, AppLocalizations l10n) async {
    
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.syncSessionCancelWarning),
        content: Text(l10n.syncSessionCancelDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('No')
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.palette.danger),
            child: Text(l10n.syncSessionCancelConfirm),
          )
        ],
      )
    );

    if(shouldCancel == true && context.mounted) {
      context.read<SyncSessionBloc>().add(const SyncSessionCancelled());
    }
  }
}