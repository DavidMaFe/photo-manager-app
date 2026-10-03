import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/config/theme/app_palette.dart';
import 'package:photo_manager_app/core/widgets/app_card.dart';
import 'package:photo_manager_app/core/widgets/app_switch.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_bloc.dart';
import 'package:photo_manager_app/features/sync_config/presentation/bloc/sync_config_event.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

/// Master switch for automatic backups.
class AutoSyncToggleWidget extends StatelessWidget {
  final bool isEnabled;

  const AutoSyncToggleWidget({super.key, required this.isEnabled});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.palette;

    return AppCard(
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: p.accentSoft, borderRadius: BorderRadius.circular(14)),
            child: Icon(Symbols.cloud_sync_rounded, size: 24, color: p.accentInk),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.autoSync, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink)),
                Text(
                  l10n.autoBackupBody,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink2),
                ),
              ],
            ),
          ),
          AppSwitch(
            value: isEnabled,
            semanticLabel: l10n.autoSync,
            onChanged: (value) => context.read<SyncConfigBloc>().add(ToggleAutoSync(value)),
          ),
        ],
      ),
    );
  }
}
