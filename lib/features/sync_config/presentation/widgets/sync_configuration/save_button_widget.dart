import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class SaveButtonWidget extends StatelessWidget {
  final bool isSaving;

  const SaveButtonWidget({
    super.key,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isSaving
            ? null
            : () {
                context.read<SyncConfigBloc>().add(SaveSyncConfig());
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.palette.accent,
          foregroundColor: context.palette.onAccent,
          disabledBackgroundColor: context.palette.line,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: isSaving
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(context.palette.onAccent),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(l10n.savingConfiguration),
                ],
              )
            : Text(
                l10n.saveConfiguration,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
