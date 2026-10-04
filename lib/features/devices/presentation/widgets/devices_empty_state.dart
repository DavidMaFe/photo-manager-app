import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:photo_manager_app/core/widgets/empty_state.dart';
import 'package:photo_manager_app/l10n/app_localizations.dart';

class DevicesEmptyState extends StatelessWidget {
  const DevicesEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return EmptyState(
      icon: Symbols.devices_rounded,
      title: l10n.noDevices,
      message: l10n.noDevicesDescription,
    );
  }
}
